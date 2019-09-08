# istio-project


## Steps:

- Create cluster using Terraform
- Create namespace book

```
kubectl create namespace book
kubectl config view
kubectl config current-context
```

To define a context for the kubectl client to work in each namespace. The value of “cluster” and “user” fields are copied from the current context.
```
kubectl config set-context dev --namespace=book \
  --cluster=<cluster_name> \
  --user=<user_name>

kubectl config use-context dev
```


### Install Istio custom resources on K8s:

```
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done

```
Verify the installed resources:

```
kubectlgetall book
```

### Install Istio permissive mutual TLS

```
kubectl apply -f install/kubernetes/istio-demo.yaml
```
- This variant provides client to send plaintext traffic. All services accept both plaintext and mutual TLS traffic.

#### Verifying the installation

- Ensure the following Kubernetes services are deployed and verify they all have an appropriate CLUSTER-IP except the jaeger-agent service
  kubectl get po,svc -n istio-system

The default Istio installation uses automatic sidecar injection. Label the namespace that will host the application with `istio-injection=enabled`:
```
kubectl label namespace book istio-injection=enabled
```

Refer the example link:
https://istio.io/docs/examples/bookinfo/

#### Deploy your application using the kubectl command:

```
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

To confirm that the Bookinfo application is running, send a request to it by a curl command from some pod, for example from ratings:
```
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
```

Confirm all services and pods are correctly defined and running:
```
kubectl get po,svc,deployments -n book
```

#### Determining the ingress IP and ports
```
kubectl get svc istio-ingressgateway -n istio-system
```

Follow these instructions if you have determined that your environment has an external load balancer.
```
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
```

Follow these instructions if you have determined that your environment does not have an external load balancer, so you need to use a node port instead.
```
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
````

### Enable Kiali

#### Install Via Helm
Once you create the Kiali secret, follow the Helm install instructions to install Kiali via Helm. You must use the --set kiali.enabled=true option when you run the helm command, for example:
```
helm template --set kiali.enabled=true install/kubernetes/helm/istio --name istio --namespace istio-system > $HOME/istio.yaml
kubectl apply -f $HOME/istio.yaml
```

To open the Kiali UI, execute the following command in your Kubernetes environment:
```
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
```

Refer: https://istio.io/docs/tasks/telemetry/kiali/


#### Traffic sniffing

- Choose any one of the pod
- sh into the pod
- run the following commands,
    `apt-get update`
    `apt-get install tcpdump`
    `tcpdump -lnAXi any -s0 --dont-verify-checksums -vv -n 'host 10.8.0.9 and port 9080'`

### Others
https://istio.io/docs/examples/bookinfo/#apply-default-destination-rules
