#!/bin/bash

echo 'Creating a K8s Deployment YAML file......'
sleep 1

# Input parameters
read -p "Enter a Deployment Name (e.g., portfolio): " dn
read -p "Enter an Image Name : " in
read -p "Enter Number of Replicas : " repn
read -p "Enter a File Name: " fn


read -p "Enter a Port Type (e.g., NodePort): " pt
read -p "Enter a Target Port Number (e.g., 8000 for django apps): " tp



# Create deployment YAML
kubectl create deployment "$dn" --image="$in" --replicas="$repn" --dry-run=client -o yaml > "$fn.yaml"
echo "Created $fn.yaml file"
sleep 1
echo "Applying Deployment YAML..."
kubectl apply -f "$fn.yaml"
sleep 5
echo "Creating Service..."
kubectl expose deployment "$dn" --type="$pt" --port=80 --target-port="$tp" --dry-run=client -o yaml >> "$fn.yaml"
echo "Applying Service YAML..."
kubectl apply -f "$fn.yaml"
sleep 5



# Wait for Pod Readiness
echo "Waiting for pod to become ready..."
kubectl wait --for=condition=ready pod -l app="$dn" --timeout=60s

# Check if pods are running
if ! kubectl get pods -l app="$dn" | grep -q 'Running'; then
  echo "Error: Pods are not running. Check deployment or image configuration."
  exit 1
fi

# Display resources
kubectl get all

# Port forwarding
echo "Deployment Successful..."
echo "Starting Port Forwarding..."
echo "Deployed Successfully. Access the app at http://localhost:$tp"

kubectl port-forward service/"$dn" "$tp":80 &


# kubectl delete all --all