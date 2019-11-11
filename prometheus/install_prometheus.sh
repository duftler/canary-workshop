# Need K8S v1.14.0 or later
# Need 6 nodes

cd ~/canary-workshop/prometheus

rm -rf kube-prometheus
git clone https://github.com/coreos/kube-prometheus.git
cd kube-prometheus

# From: https://github.com/coreos/kube-prometheus#quickstart
kubectl apply -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f manifests/
