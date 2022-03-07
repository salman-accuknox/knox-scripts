#!/bin/bash
kubectl create serviceaccount sa
sleep 3
kubectl create clusterrolebinding crb --clusterrole=cluster-admin --serviceaccount=default:sa
sleep 3
secret_name=$(kubectl get secrets -o name | grep sa-token)
sleep 3
export TOKEN=$(kubectl get $secret_name -o=jsonpath="{.data.token}" | base64 --decode)
sleep 3
echo $TOKEN
