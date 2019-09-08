#!/usr/bin/env bash

printf "\n---------\n"
echo "Create kubernetes cluster using terraform commands"

pushd terraform
# terraform init
# terraform validate
# terraform plan
# terraform apply
popd

sleep 5


echo "Create cluster through Terraform commands"
gcloud container clusters get-credentials caribbean-cluster --zone us-west1-a --project thrashingcorecode-249409



# Install istio
printf "\n---------\n"
echo "Create kubernetes cluster using terraform commands"

sleep 5

curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.5 sh -

printf "\n After downloading, move the istioctl to your local bin directory, \n"
cp istio-1.0.0/bin/istioctl /usr/local/bin/

printf "\n Verify the path one more time \n"
which istioctl

printf "\n---------\n"
echo "Create book namespace"

kubectl create namespace book
kubectl config current-context

printf "\n---------\n"
echo "Update the context to book namespace. This ensures istio components will be installed on this namespace"


kubectl config set-context dev --namespace=book \
 --cluster=gke_thrashingcorecode-249409_us-west1-a_caribbean-cluster \
 --user=gke_thrashingcorecode-249409_us-west1-a_caribbean-cluster

kubectl config use-context dev
kubectl config current-context

sleep 5

printf "\n---------\n"
echo "Install Istio custom resources on K8s"

pushd istio-1.2.5

for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done

printf "\n---------\n"
echo "Verify the installed resources:"

function kubectlgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl -n ${1} get --ignore-not-found ${i}
  done
}

# kubectlgetall book

printf "\n---------\n"
echo "Install Istio permissive mutual TLS"

kubectl apply -f install/kubernetes/istio-demo.yaml

printf "\n---------\n"
echo "kubectl get po,svc -n istio-system"

printf "\n---------\n"
echo "Enable istio sidecar injection in book namespace"

kubectl label namespace book istio-injection=enabled

printf "\n---------\n"
echo "Deploy Book application using the kubectl command:"

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

while [[ $(kubectl get pods -l app=productpage -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
while [[ $(kubectl get pods -l app=details -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
while [[ $(kubectl get pods -l app=reviews,version=v1 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

printf "\n---------\n"
echo "To confirm that the Bookinfo application is running, send a request to it by a curl command from some pod, for example from ratings:"

kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"

printf "\n---------\n"
echo "Confirm all services and pods are correctly defined and running:"

kubectl get po,svc,deployments -n book

sleep 5

printf "\n---------\n"
echo "Apply gateway"

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl get gateway

sleep 5

printf "\n---------\n"
echo "Determining the ingress IP and ports"

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>"

echo "Enable mTLS"
kubectl apply -f samples/bookinfo/networking/destination-rule-all-mtls.yaml
