#!/bin/bash
set -e
baseUrl='https://api.cloudflare.com/client/v4'
token=$CLOUDFLARE_TOKEN
zoneId=$CLOUDFLARE_ZONE_ID
recordId=$CLOUDFLARE_RECORD_ID
myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
#!/bin/bash

function getUrl(){
    path=$1
    curl -sX GET \
    "${baseUrl}/${path}" \
    -H "Authorization: Bearer ${token}"  \
    -H "Content-Type:application/json"  \
    | jq -r .
}

function postUrl(){
    
    path=$1
    data=$2
    curl -sX POST \
    "${baseUrl}/${path}" \
    -H "Authorization: Bearer ${token}"  \
    -H "Content-Type:application/json"  \
    --data "${data}"  \
    | jq -r .
}

function putUrl(){
    
    path=$1
    data=$2
    curl -sX PUT \
    "${baseUrl}/${path}" \
    -H "Authorization: Bearer ${token}"  \
    -H "Content-Type:application/json"  \
    --data "${data}" \
    | jq -r .
}

generate_post_data()
{
  cat <<EOF
{
  "type": "A",
  "name": "bcn.crypto-pool.net",
  "content": "$myip",
  "ttl": 120,
  "priority": 10,
  "proxied": false
}
EOF
}

#getUrl 'user/token/verify'
#getUrl 'zones'
#getUrl "zones/${zoneId}/dns_records"
#postUrl "zones/${zoneId}/dns_records" "$(generate_post_data)"
putUrl "zones/${zoneId}/dns_records/${recordId}" "$(generate_post_data)"