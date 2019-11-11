~/hal/hal config canary google edit --stackdriver-enabled false

~/hal/hal config canary prometheus account add my-prometheus --base-url http://prometheus-k8s.monitoring:9090
~/hal/hal config canary prometheus enable

~/hal/hal config provider kubernetes account edit spinnaker-install-account --omit-namespaces "halyard,kube-public,kube-system,spinnaker,monitoring"

~/spinnaker-for-gcp/scripts/manage/push_and_apply.sh