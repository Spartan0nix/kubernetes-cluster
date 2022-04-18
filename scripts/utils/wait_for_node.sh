#!/bin/bash

#cat status.json | jq .items[0].metadata.name
node_started="false"
ready_state="\"True\""

check_status() {
	node_index=$(cat status.json | jq '.items | keys[]')
	counter=0

	echo "#"
	echo "# $(date)"
	echo "#"

	for index in $node_index
	do
		node_name=$(cat status.json | jq .items[$index].metadata.name)
		node_ready=$(cat status.json | jq .items[$index].status.conditions[] | jq '. | select(.reason=="KubeletReady").status')

		if [ $node_ready != $ready_state ];then
			echo "${node_name} => Is ready : ${node_ready}"
			node_started="false"
			counter=$((counter+1))
		fi

		if [ $counter -eq 0 ];then
			node_started="true"
		fi
	done
}

echo "---------------------------------------------"
echo "-         Waiting for nodes to start        -"
echo "---------------------------------------------"
while [ $node_started != "true" ]
do
	kubectl get node -o json > status.json
	check_status
	sleep 10
done

echo "All nodes started successfully"
rm -rf status.json

