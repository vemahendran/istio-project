
pushd istio-1.2.5

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

popd
