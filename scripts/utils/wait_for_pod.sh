#!/bin/sh

#cat status.json | jq .items[0].metadata.name
pod_started="false"

check_status() {
	pod_index=$(cat status.json | jq '.items | keys[]')
	counter=0

	echo "#"
	echo "# $(date)"
	echo "#"

	for index in $pod_index
	do
		pod_name=$(cat status.json | jq .items[$index].metadata.name)
		pod_status=$(cat status.json | jq .items[$index].status.phase)

		if [ $pod_status != "\"Running\"" ];then
			echo "${pod_name} => Status is : ${pod_status}"
			pod_started="false"
			counter=$((counter+1))
		fi

		if [ $counter -eq 0 ];then
			pod_started="true"
		fi
	done
}

echo "---------------------------------------------"
echo "-         Waiting for pods to start         -"
echo "---------------------------------------------"
while [ $pod_started != "true" ]
do
	if [ $# -eq 1 ];then
		kubectl get pod -n $1 -o json > status.json
	else
		kubectl get pod -A -o json > status.json
	fi
	check_status
	sleep 10
done

echo "All pods started successfully"
rm -rf status.json

