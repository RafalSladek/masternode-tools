# masternode-tools

shell scripts for monitoring my masternodes

## Setup

1. You need to export system/profile env variable
   `export DATADOG_API_KEY=<YOUR_DATADOG_API_HERE>`

2. clone this repo into `<YOUR_DIR>`, for example `/usr/local/src`
3. run `bash setup.sh`

## Deployment

You can use following command and crontab to do autodeployment after git commit

1. switch to root `sudo su`
2. open crontab editor `crontab -e`
3. paste following line at the bottomg of the list `*/1 * * * * cd /usr/local/src/masternode-tools && /usr/bin/git pull --rebase && bash setup.sh`

It will pull from git every minute (https://crontab.guru/#*/1_*_*_*_*) and install all scripts which are executable

## How to use the datadog helper function `sentMetric()`

```
source /usr/local/bin/ddhelper.sh

sentMetric $host $coin $metricname $value $role $username
```

## How to use the datadog helper function `sentEvent()`

```
source /usr/local/bin/ddhelper.sh

// alert_type is option, default is info
sentMetric $host $coin $title $message $role $username <alert_type>
```

## How to setup forge node

1. https://github.com/HorizenOfficial/compose-evm-simplified/blob/main/docs/FORGER.md
2. https://github.com/HorizenOfficial/eon-smart-contract-tools
3. https://remix.ethereum.org/#source=post_page-----2f0ac541130c--------------------------------&lang=en&optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.25+commit.b61c2a91.js
4. https://gitlab.com/Kryptoroger/eon-smart-contract-tools
5. https://eon-explorer.horizenlabs.io/
