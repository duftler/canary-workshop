if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud info --format='value(config.project)')
fi

if [ -z "$PROJECT_ID" ]; then
  echo "Please set PROJECT_ID env var."
  exit 1
fi

export PROJECT_ID

# Create application 'workshop'
~/spin application save --application-name workshop --owner-email test@some-domain.com --cloud-providers "kubernetes"

# Create pipeline 'Bootstrap' in application 'workshop'
envsubst < ~/canary-workshop/templates/bootstrap_template.json | ~/spin pipeline save

# Run pipeline 'Bootstrap'
~/spin pipeline execute --application workshop --name Bootstrap

# Create pipeline 'Deploy Canary' in application 'workshop'
envsubst < ~/canary-workshop/templates/deploy_canary_template.json | ~/spin pipeline save

export DEPLOY_CANARY_REF=$(~/spin pipeline get --name 'Deploy Canary' --application workshop | jq .id)
export PROMOTE_CANARY_REF=$(~/spin pipeline get --name 'Promote Canary' --application workshop | jq .id)

# Create pipeline 'Promote Canary' in application 'workshop'
envsubst < ~/canary-workshop/templates/promote_canary_template.json | ~/spin pipeline save

# Create pipeline 'Clean Up Canary' in application 'workshop'
envsubst < ~/canary-workshop/templates/clean_up_canary_template.json | ~/spin pipeline save
