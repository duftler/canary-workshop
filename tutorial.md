# Install Spinnaker

## Select GCP project

Select the project in which you'll install Spinnaker, then click **Start**, below.

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Prerequisites

You must have installed Spinnaker for GCP prior to launching this tutorial.

## Canary Workshop Setup

```bash
PROJECT_ID={{project-id}} ~/canary-workshop/setup.sh
```

## Connect to Spinnaker

To connect to the Deck UI, click on the Preview button above and select "Preview on port 8080":

![Image](https://github.com/GoogleCloudPlatform/spinnaker-for-gcp/raw/master/scripts/manage/preview_button.png)

## Prometheus / Grafana

Click on the Prometheus and Grafana links in Cloud Shell to bring each up in its own
browser tab.

The Grafana username/password are `admin`/`admin`.