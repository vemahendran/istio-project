
printf "\n---------\n"
echo "Install Via Helm"

pushd istio-1.2.5
helm template --set kiali.enabled=true install/kubernetes/helm/istio --name istio --namespace istio-system > ../istio.yaml
popd

kubectl apply -f ./istio.yaml

printf "\n---------\n"
echo "To open the Kiali UI, execute the following command in your Kubernetes environment:""

while [[ $(kubectl get pods -n istio-system -l app=kiali -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
