#!/bin/bash

echo "Creating Kubernetes Dashboard..."
sleep 1

# Apply the Dashboard YAML
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
sleep 2
echo "Dashboard deployed successfully."
echo "..."

# Start the kubectl proxy in the background
echo "Starting kubectl proxy..."
kubectl proxy &
proxy_pid=$!  # Save the proxy process ID to kill it later if needed
# ps aux | grep kubectl
# kill -9 3701
sleep 2

echo "Access the Dashboard at:"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo "..."

# Ask the user if they want to create a Service Account
read -p "Do you want to create a Dashboard Service Account? (y/n): " create_account
if [[ $create_account == "y" || $create_account == "Y" ]]; then
    echo "Creating a Service Account..."
    kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
    sleep 1

    echo "Binding the Service Account to the Cluster Role..."
    kubectl create clusterrolebinding dashboard-admin-binding \
        --clusterrole=cluster-admin \
        --serviceaccount=kubernetes-dashboard:dashboard-admin
    sleep 1

    echo "Retrieving the Access Token..."
    token=$(kubectl -n kubernetes-dashboard create token dashboard-admin)
    echo "Access Token:"
    echo "$token"
    echo "Use the above token to log in to the Dashboard."
else
    echo "Service Account creation skipped."
fi

echo "Dashboard setup is complete."
echo "Access the Dashboard at:"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

# Provide an option to stop the kubectl proxy
read -p "Do you want to stop the kubectl proxy? (y/n): " stop_proxy
if [[ $stop_proxy == "y" || $stop_proxy == "Y" ]]; then
    echo "Stopping kubectl proxy..."
    kill $proxy_pid
    echo "kubectl proxy stopped."
else
    echo "kubectl proxy is running in the background. Use 'kill $proxy_pid' to stop it later if needed."
fi
