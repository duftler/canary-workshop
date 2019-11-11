if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud info --format='value(config.project)')
fi

if [ -z "$PROJECT_ID" ]; then
  echo "PROJECT_ID must be specified."
  exit 1
fi

set_dummy_git_config_values() {
  git config --global user.name "$USER"
  git config --global user.email "$USER@some-domain.com"
}

~/spinnaker-for-gcp/scripts/manage/check_git_config.sh || set_dummy_git_config_values

~/spinnaker-for-gcp/scripts/manage/check_cluster_config.sh

~/canary-workshop/prometheus/install_prometheus.sh

~/canary-workshop/build_and_publish_image.sh

~/spinnaker-for-gcp/scripts/manage/connect_unsecured.sh

~/canary-workshop/deploy_resources.sh

~/canary-workshop/kayenta/configure_prometheus_integration.sh

gcloud source repos create sample-app --project $PROJECT_ID
mkdir -p ~/$PROJECT_ID
gcloud source repos clone sample-app ~/$PROJECT_ID/sample-app --project $PROJECT_ID

cp -R ~/canary-workshop/sample-app/* ~/$PROJECT_ID/sample-app

cd ~/$PROJECT_ID/sample-app

git add .
git commit -m 'Initial commit.'
git push

gcloud alpha builds triggers create cloud-source-repositories \
  --repo sample-app --branch-pattern ^master$ \
  --build-config cloudbuild.yaml \
  --description "Build on push to master" --project $PROJECT_ID

~/canary-workshop/prometheus/expose_prometheus.sh
