# Check if PROJECT_ID is set and err if not
# Enable required services (kubernetes and cloudbuild?)

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud info --format='value(config.project)')
fi

if [ -z "$PROJECT_ID" ]; then
  echo "Please set PROJECT_ID env var."
  exit 1
fi

export PROJECT_ID

cd ~/canary-workshop/sample-app

gcloud builds submit --tag gcr.io/$PROJECT_ID/sample-app . --project $PROJECT_ID
