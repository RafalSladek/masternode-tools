# masternode-tools
shell scripts for monitoring my masternodes

## Setup
1. You need to export system/profile env variable
```export DATADOG_API_KEY=<YOUR_DATADOG_API_HERE>```

2. clone this repo into `<YOUR_DIR>`, for example `/usr/local/src`
3. run `bash setup.sh`

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

## How to use wallet|alert notify script

1. edit your coin config file
2. for wallet transactions use
`walletnotify=/usr/local/bin/walletnotifyCROP %s`
3. for daemon alerts use
`alertnotify=/usr/local/bin/alertnotifyCROP %s`