#!/usr/bin/env bash

printf "\n---------\n"
echo "Create kubernetes cluster using terraform commands"

pushd terraform
terraform init
terraform validate
terraform plan
terraform apply
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

popd
