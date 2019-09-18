
printf "\n---------\n"
echo "Determining the ingress IP and ports"

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl http://$GATEWAY_URL/demo-service/v1.0/ships/test/names

watch -n 1 curl -o /dev/null -s -w %{http_code} $GATEWAY_URL/demo-service/v1.0/ships/test/names
