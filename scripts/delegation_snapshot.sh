#!/bin/bash

##############################################################################
# This script uses the Blockfrost API to fetch all stake keys currently 
# delegated to a Stake Pool specified by $poolID along with their known 
# addresses and writes their respective PubKeyHashes to snapshot.txt
###############################################################################

baseURL="https://cardano-preview.blockfrost.io/api/v0/"
projectID=""
poolID=""

stake_keys=$(curl -s "${baseURL}/pools/${poolID}/delegators" \
    -H "project_id: ${projectID}" | jq -r "[.[] | .address]")

echo "$stake_keys" | jq -c --raw-output '.[]' |
while IFS=$"\n" read -r sKey; do
  staking_addresses=$(curl -s "${baseURL}accounts/${sKey}/addresses" \
    -H "project_id: ${projectID}" | jq -r --raw-output "[.[] | .address]")

  echo "$staking_addresses" | jq -c --raw-output '.[]' |
  while IFSS=$"\n" read -r sAddress; do
    #echo "Staking address: ${sAddress}"
    `echo $sAddress | bech32 | cut -c 3- | cut -c -56 >> snapshot.txt`
  done
done

echo "Finished writing to snapshot.txt"