if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud info --format='value(config.project)')
fi

if [ -z "$PROJECT_ID" ]; then
  echo "PROJECT_ID must be specified."
  exit 1
fi

convert_service_to_nodetype() {
  EXISTING_SERVICE_TYPE=$(kubectl get service $1 -n monitoring \
    -o jsonpath={.spec.type})

  if [ $EXISTING_SERVICE_TYPE != 'NodePort' ]; then
    echo "Patching $1 service to be NodePort instead of $EXISTING_SERVICE_TYPE..."

    kubectl patch service $1 -n monitoring --patch \
      "[{'op': 'replace', 'path': '/spec/type', \
      'value':'NodePort'}]" --type json
  else
    echo "Service $1 is already NodePort..."
  fi
}

convert_service_to_nodetype prometheus-k8s
convert_service_to_nodetype grafana

PROMETHEUS_NODE_PORT=$(kubectl get svc -n monitoring prometheus-k8s \
  -o jsonpath={.spec.ports[0].nodePort})
GRAFANA_NODE_PORT=$(kubectl get svc -n monitoring grafana \
  -o jsonpath={.spec.ports[0].nodePort})

gcloud compute firewall-rules create prometheus-node-port --allow tcp:$PROMETHEUS_NODE_PORT \
  --project $PROJECT_ID
gcloud compute firewall-rules create grafana-node-port --allow tcp:$GRAFANA_NODE_PORT \
  --project $PROJECT_ID

FIRST_NODE_EXTERNAL_IP=$(kubectl get nodes \
  -o jsonpath='{$.items[0].status.addresses[?(@.type=="ExternalIP")].address}')

GRAFANA_ADDRESS=$FIRST_NODE_EXTERNAL_IP:$GRAFANA_NODE_PORT

cd ~/canary-workshop/prometheus

curl -d "@grafana-dashboard.json" \
  -H "Content-Type: application/json" \
  -X POST http://admin:admin@$GRAFANA_ADDRESS/api/dashboards/db

echo
echo
echo "Access Prometheus here: http://$FIRST_NODE_EXTERNAL_IP:$PROMETHEUS_NODE_PORT"
echo "Access Grafana here: http://$GRAFANA_ADDRESS"
echo "Access newly-created Grafana dashboard here: http://$GRAFANA_ADDRESS/d/rbcn181Zz"
