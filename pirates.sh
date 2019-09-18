#!/usr/bin/env bash


printf "\n---------\n"
echo "Create pirates namespace"

kubectl create namespace pirates
kubectl config current-context

printf "\n---------\n"
echo "Update the context to pirates namespace. This ensures istio components will be installed on this namespace"


kubectl config set-context dev --namespace=pirates \
 --cluster=gke_thrashingcorecode-249409_us-west1-a_caribbean-cluster \
 --user=gke_thrashingcorecode-249409_us-west1-a_caribbean-cluster

kubectl config use-context dev
kubectl config current-context


# pushd istio-1.2.5

printf "\n---------\n"
echo "Enable istio sidecar injection in pirates namespace"

kubectl label namespace pirates istio-injection=enabled

printf "\n---------\n"
echo "Deploy pirates application using the kubectl command:"

for i in ./manifests/**/*.yml; do kubectl apply -f $i; done

while [[ $(kubectl get pods -l app=demo-service -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
while [[ $(kubectl get pods -l app=blackpearlserv-service -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
while [[ $(kubectl get pods -l app=flyingdutchmanserv-service -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

printf "\n---------\n"
echo "To confirm that the pirates application is running, send a request to it by a curl command from some pod, for example from ratings:"

# kubectl exec -it $(kubectl get pod -l app=blackpearlserv-service -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"

printf "\n---------\n"
echo "Confirm all services and pods are correctly defined and running:"

kubectl get po,svc,deployments -n pirates

sleep 5

printf "\n---------\n"
echo "Apply gateway"

kubectl get gateway

sleep 5

printf "\n---------\n"
echo "Determining the ingress IP and ports"

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl -s http://${GATEWAY_URL}/demo-service/v1.0/names


# popd
