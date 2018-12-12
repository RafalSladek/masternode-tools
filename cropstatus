#!/bin/bash
CROPUSER=cropcoin
PUBLIC_IP=$(curl -s ipecho.net/plain)
sudo -u $CROPUSER -H sh -c "echo '{ \"timestamp\": \"`date`\", \"details\": ['; cropcoind masternode status; echo ','; cropcoind getinfo; echo ','; cropcoind masternode list full $PUBLIC_IP; echo ']}'"