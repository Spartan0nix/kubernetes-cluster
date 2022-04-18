#!/bin/bash

kubectl get csr -o json > csr.json

csr_list_index=$(kubectl get csr -o json | jq '.items | keys[]')

for index in $csr_list_index
do
        csr_name=$(cat csr.json | jq ".items[$index].metadata.name" | sed 's/\"//g')        
        csr_status=$(cat csr.json | jq ".items[$index].status | length")
        
        if [[ $csr_status -eq 0 ]];then
                csr_username=$(cat csr.json | jq ".items[$index].spec.username")
                if [[ $csr_username == *"$1"* ]];then
                        echo "[csr-approving] : approving csr '$csr_name', for '$1'."       
                        kubectl certificate approve $csr_name
                fi
        fi
done

rm -rf csr.json