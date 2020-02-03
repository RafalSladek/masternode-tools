#!/bin/bash

#set -exuo pipefail
set -x

DEFAULTCOINUSER="chaincoin"
COINUSER=""
COINHOME=$DEFAULTCOINUSER
DEFAULTCOINPORT=11994
DEFAULTORGANAME="chaincoincore"

COINTITLE="Chaincoin"
COINDAEMON="chaincoind"
COINCLI="chaincoin-cli"
CONFIG_FILE="chaincoin.conf"
COIN_REPO="https://github.com/ChainCoin/ChainCoin.git"

TMP_FOLDER=$(mktemp -d)
BIN_TARGET="/usr/local/bin"
BINARY_FILE="${BIN_TARGET}/${COINDAEMON}"

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
if ! [[ $(lsb_release -d) == *16.04* || $(lsb_release -d) == *Raspbian* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COINDAEMON)" ]; then
  echo -e "${GREEN}\c"
  read -e -p "$COINDAEMON is already running. Do you want to add another MN? [Y/N]" NEW_COIN
  echo -e "{NC}"
else
  NEW_COIN="new"
fi
}

function prepare_system() {
echo -e "Prepare the system to install $COINTITLE master node."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
        git wget pwgen curl ufw tree vim htop \
        libprotobuf-dev libevent-dev libzmq3-dev \
        libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev \
        automake build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev \
        libminiupnpc-dev software-properties-common python-software-properties g++ \
        libdb4.8-dev libdb4.8++-dev


if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y         
        git wget pwgen curl ufw tree vim htop \
        libprotobuf-dev libevent-dev libzmq3-dev \
        libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev \
        automake libdb++-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev \
        libminiupnpc-dev software-properties-common python-software-properties g++ \
        libdb4.8-dev libdb4.8++-dev python-virtualenv virtualenv"
 exit 1
fi

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
}

function compile() {
  echo "compile..."
  echo -e "Clone git repo and compile it. This may take some time."

  git clone $COIN_REPO $TMP_FOLDER -b 0.16
  cd $TMP_FOLDER
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make install
  compile_error $DEFAULTCOINUSER
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow incomning access on port ${GREEN}$COINPORT${NC}"
  ufw allow $COINPORT/tcp comment "$COINTITLE MN port" >/dev/null
  ufw allow $[COINPORT+1]/tcp comment "$COINTITLE RPC port" >/dev/null
  ufw allow ssh >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

function systemd_install() {
  cat << EOF > /etc/systemd/system/$COINUSER.service
[Unit]
Description=$COINTITLE service
After=network.target

[Service]

Type=forking
User=$COINUSER
Group=$COINUSER
WorkingDirectory=$COINHOME
ExecStart=$BIN_TARGET/$COINDAEMON -daemon
ExecStop=$BIN_TARGET/$COINCLI stop

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

  if [[ -z $(pidof $COINDAEMON) ]]; then
    echo -e "${RED}${COINTITLE} is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo "systemctl start $COINUSER.service"
    echo "systemctl status $COINUSER.service"
    echo "less /var/log/syslog"
    exit 1
  fi
}

function ask_port() {
read -p "$COINTITLE Port: " -i $DEFAULTCOINPORT -e COINPORT
: ${COINPORT:=$DEFAULTCOINPORT}
}

function ask_user() {
  read -p "$COINTITLE user: " -i $DEFAULTCOINUSER -e COINUSER
  : ${COINUSER:=$DEFAULTCOINUSER}

  if [ -z "$(getent passwd $COINUSER)" ]; then
    useradd -m $COINUSER
    COINHOME=$(sudo -H -u $COINUSER bash -c 'echo $HOME')
    DEFAULTCOINFOLDER="${COINHOME}/.${DEFAULTORGANAME}"
    read -p "Configuration folder: " -i $DEFAULTCOINFOLDER -e COINFOLDER
    : ${COINFOLDER:=$DEFAULTCOINFOLDER}
    mkdir -p $COINFOLDER
    chown -R $COINUSER: $COINFOLDER >/dev/null
    USERPASS=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w12 | head -n1)
    echo "$COINUSER:$USERPASS" | chpasswd
  else
    echo -e "${RED}User exits. Please enter another username: ${NC}"
    ask_user
  fi
}

function check_port() {
  declare -a PORTS
  PORTS=($(netstat -tnlp | awk '/LISTEN/ {print $4}' | awk -F":" '{print $NF}' | sort | uniq | tr '\r\n'  ' '))
  ask_port

  while [[ ${PORTS[@]} =~ $COINPORT ]] || [[ ${PORTS[@]} =~ $[COINPORT+1] ]]; do
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
  sudo -u $COINUSER $BIN_TARGET/$COINDAEMON -conf=$COINFOLDER/$CONFIG_FILE -datadir=$COINFOLDER
  sleep 5
    if [ -z "$(pidof $COINDAEMON)" ]; then
    echo -e "${RED}Arcticcoind server couldn't start. Check /var/log/syslog for errors.{$NC}"
    exit 1
    fi
  COINKEY=$(sudo -u $COINUSER $BIN_TARGET/$COINCLI -conf=$COINFOLDER/$CONFIG_FILE -datadir=$COINFOLDER masternode genkey)
  sudo -u $COINUSER $BIN_TARGET/$COINCLI -conf=$COINFOLDER/$CONFIG_FILE -datadir=$COINFOLDER stop
  fi
}

function update_config() {
  NODEIP=$(curl -s4 api.ipify.org)
  sed -i 's/daemon=1/daemon=0/' $COINFOLDER/$CONFIG_FILE
  cat << EOF >> $COINFOLDER/$CONFIG_FILE
logtimestamps=1
maxconnections=256
masternode=1
externalip=$NODEIP
masternodeprivkey=$COINKEY
EOF
  chown -R $COINUSER: $COINFOLDER >/dev/null
}

function important_information() {
 echo
 echo -e "================================================================================================================================"
 echo -e "$COINTITLE Masternode is up and running as user ${GREEN}$COINUSER${NC} and it is listening on port ${GREEN}$COINPORT${NC}."
 echo -e "${GREEN}$COINUSER${NC} password is ${RED}$USERPASS${NC}"
 echo -e "Configuration file is: ${RED}$COINFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COINUSER.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COINUSER.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COINPORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "================================================================================================================================"
}

function status() {
cat << EOF >> ${BIN_TARGET}/chainstatus
#!/bin/bash
PUBLIC_IP='$(curl -s ipecho.net/plain)'
sudo -u '$COINUSER' -H sh -c "echo '{ \"timestamp\": \"`date`\", \"details\": ['; $COINCLI getinfo; echo ','; $COINCLI masternode list full '$PUBLIC_IP'; echo ']}'"
EOF

chmod +x ${BIN_TARGET}/chainstatus
}

function motd() {
  cat << EOF >> /etc/update-motd.d/99-${DEFAULTCOINUSER}
#!/bin/bash
printf "\n${COINCLI} masternode status\n"
${BIN_TARGET}/chainstatus
printf "\n"
EOF
chmod +x /etc/update-motd.d/99-${DEFAULTCOINUSER}
}

function sentinel() {

sudo -u "$COINUSER" -H sh -c 'git clone https://github.com/chaincoin/sentinel.git'
sudo -u "$COINUSER" -H sh -c 'cd sentinel && virtualenv ./venv && ./venv/bin/pip install -r requirements.txt'
sudo crontab -u $COINUSER -e
sudo echo "* * * * * cd $COINHOME/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> /var/spool/cron/crontabs/$COINUSER
}

function setup_node() {
  echo "setup node..."
  ask_user
  check_port
  create_config
  create_key
  update_config
  enable_firewall
  systemd_install
  important_information
  status
  motd
  sentinel
}

##### Main #####


checks
if [[ ("$NEW_COIN" == "y" || "$NEW_COIN" == "Y") ]]; then
  setup_node
  exit 0
elif [[ "$NEW_COIN" == "new" ]]; then
  prepare_system
  compile
  setup_node
  exit 0
else
  echo -e "${GREEN}$COINDAEMON already running.${NC}"
  exit 0
fi
