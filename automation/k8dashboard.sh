#!/bin/bash

echo 'Creating Kluster Dashboard........'
sleep 1
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
sleep 1
echo '.............'


sleep 1
kubectl proxy &
sleep 1


echo 'Access the Dashboard at  http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'


read -p "Do you want to create a Dashboard Servcie account (y/n): "
echo 'Creating a Service Account......'
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
sleep 1

echo 'Bind the Service Account to a Cluster Role'
sleep 1
kubectl create clusterrolebinding dashboard-admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=kubernetes-dashboard:dashboard-admin

sleep 1
echo 'Retrieve the Access Token'
kubectl -n kubernetes-dashboard create token dashboard-admin

echo 'http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'





