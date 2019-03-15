=========================================="
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

