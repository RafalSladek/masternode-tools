#!/bin/bash
#set -xoue
COIN=zen
BACKUP_TARGET_DIR=/root
WALLET_FILEPATH=/home/${COIN}/.${COIN}/wallet.dat

7z a -p backup.$FQDN.7z ${WALLET_FILEPATH}