#!/bin/bash
set -xeu
COIN="bytecoin"
CLI_NAME="${COIN}-cli"
DAEMON_NAME="${COIN}d"
TMP_FOLDER=$(mktemp -d)
CONFIG_FILE="${COIN}.conf"
BINARY_FILE="/usr/local/bin/${DAEMON_NAME}"
BINARY_FILE_CLI="/usr/local/bin/${CLI_NAME}"
COIN_CORE=".${COIN}"
TAG_VERSION="3.4.1"
COIN_TGZ_FILENAME="${COIN_CORE}-daemons-${TAG_VERSION}-linux64.zip"
COIN_TGZ="https://github.com/bcndev/${COIN}/releases/download/v${TAG_VERSION}/${COIN_TGZ_FILENAME}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $@. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]] && [[ $(lsb_release -d) != *stretch* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. or Debian. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof ${DAEMON_NAME})" ]; then
  echo -e "${GREEN}\c"
  read -e -p "${DAEMON_NAME} is already running. Do you want to add another MN? [Y/N]" NEW_COIN
  echo -e "{NC}"
  clear
else
  NEW_COIN="new"
fi
}

function prepare_system() {

echo -e "Prepare the system to install ${DAEMON_NAME} master node."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils \
libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pwgen unzip

if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git pwgen curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw unzip"
 exit 1
fi

clear
echo -e "Checking if swap space is needed."
PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
SWAP=$(swapon -s)
if [[ "$PHYMEM" -lt "2" && -z "$SWAP" ]];
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM, creating 2G swap file.${NC}"
    dd if=/dev/zero of=/swapfile bs=1024 count=2M
    chmod 600 /swapfile
    mkswap /swapfile
    swapon -a /swapfile
else
  echo -e "${GREEN}The server running with at least 2G of RAM, or SWAP exists.${NC}"
fi
clear
}

function deploy_binaries() {
  cd /tmp
  wget -q $COIN_TGZ
  unzip "${COIN_TGZ_FILENAME}"
  mv bytecoind /usr/local/bin  >/dev/null 2>&1
  mv walletd /usr/local/lib  >/dev/null 2>&1
  mv minerd /usr/local/include  >/dev/null 2>&1
  rm "${COIN_TGZ_FILENAME}" >/dev/null 2>&1
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow incomning access on port ${GREEN}$COINPORT${NC}"
  ufw allow $COINPORT/tcp comment "${COIN} MN port" >/dev/null
  ufw allow $[COINPORT+1]/tcp comment "${COIN} RPC port" >/dev/null
  ufw allow ssh >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

function systemd_coin() {
  cat << EOF > /etc/systemd/system/$COINUSER.service
[Unit]
Description=${COIN} service
After=network.target

[Service]

Type=forking
User=$COINUSER
Group=$COINUSER
WorkingDirectory=$COINHOME
ExecStart=$BINARY_FILE -daemon
ExecStop=$BINARY_FILE stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
  
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COINUSER.service
  systemctl enable $COINUSER.service >/dev/null 2>&1

  if [[ -z $(pidof ${DAEMON_NAME}) ]]; then
    echo -e "${RED}${DAEMON_NAME} is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo "systemctl start $COINUSER.service"
    echo "systemctl status $COINUSER.service"
    echo "less /var/log/syslog"
    exit 1
  fi
}

function ask_port() {
DEFAULTCOINPORT=8081
read -p "${COIN} Port: " -i $DEFAULTCOINPORT -e COINPORT
: ${COINPORT:=$DEFAULTCOINPORT}
}

function ask_user() {
  DEFAULTCOINUSER="${COIN}"
  read -p "${COIN} user: " -i $DEFAULTCOINUSER -e COINUSER
  : ${COINUSER:=$DEFAULTCOINUSER}

  if [ -z "$(getent passwd $COINUSER)" ]; then
    useradd -m $COINUSER
    USERPASS=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w12 | head -n1)
    echo "$COINUSER:$USERPASS" | chpasswd

    COINHOME=$(sudo -H -u $COINUSER bash -c 'echo $HOME')
    DEFAULTCOINFOLDER="$COINHOME/.${COIN_CORE}"
    read -p "Configuration folder: " -i $DEFAULTCOINFOLDER -e COINFOLDER
    : ${COINFOLDER:=$DEFAULTCOINFOLDER}
    mkdir -p $COINFOLDER
    chown -R $COINUSER: $COINFOLDER >/dev/null
  else
    clear
    echo -e "${RED}User exits. Please enter another username: ${NC}"
    ask_user
  fi
}

function check_port() {
  declare -a PORTS
  PORTS=($(netstat -tnlp | awk '/LISTEN/ {print $4}' | awk -F":" '{print $NF}' | sort | uniq | tr '\r\n'  ' '))
  ask_port

  while [[ ${PORTS[@]} =~ $COINPORT ]] || [[ ${PORTS[@]} =~ $[COINPORT+1] ]]; do
    clear
    echo -e "${RED}Port in use, please choose another port:${NF}"
    ask_port
  done
}

function create_config() {
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $COINFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=$[COINPORT+1]
listen=1
server=1
daemon=1
port=$COINPORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  sudo -u $COINUSER /usr/local/bin/${DAEMON_NAME} -conf=$COINFOLDER/$CONFIG_FILE -datadir=$COINFOLDER
  sleep 30
  if [ -z "$(pidof ${DAEMON_NAME})" ]; then
   echo -e "${RED}${DAEMON_NAME} server couldn't start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$(sudo -u $COINUSER $BINARY_FILE_CLI -conf=$COINFOLDER/$CONFIG_FILE -datadir=$COINFOLDER goldminenode genkey)
  sudo -u $COINUSER $BINARY_FILE_CLI -conf=$COINFOLDER/$CONFIG_FILE -datadir=$COINFOLDER stop
fi
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $COINFOLDER/$CONFIG_FILE
  NODEIP=$(curl -s4 api.ipify.org)
  cat << EOF >> $COINFOLDER/$CONFIG_FILE
logtimestamps=1
maxconnections=256
goldminenode=1
externalip=$NODEIP
goldminenodeprivkey=$COINKEY
EOF
  chown -R $COINUSER: $COINFOLDER >/dev/null
}

function important_information() {
 echo
 echo -e "================================================================================================================================"
 echo -e "${COIN} Masternode is up and running as user ${GREEN}$COINUSER${NC} and it is listening on port ${GREEN}$COINPORT${NC}."
 echo -e "${GREEN}$COINUSER${NC} password is ${RED}$USERPASS${NC}"
 echo -e "Configuration file is: ${RED}$COINFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COINUSER.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COINUSER.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COINPORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "================================================================================================================================"
}

function setup_node() {
  ask_user
  check_port
  create_config
  create_key
  update_config
  enable_firewall
  systemd_coin
  important_information
}


##### Main #####
clear

checks
if [[ ("$NEW_COIN" == "y" || "$NEW_COIN" == "Y") ]]; then
  setup_node
  exit 0
elif [[ "$NEW_COIN" == "new" ]]; then
  prepare_system
  #deploy_binaries
  setup_node
else
  echo -e "${GREEN}${DAEMON_NAME} already running.${NC}"
  exit 0
fi

