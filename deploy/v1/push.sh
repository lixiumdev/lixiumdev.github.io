#!/bin/bash

# it is assumed that "yq" is installed by default here!

git config --global user.name "GitHub Actions Bot"
git config --global user.email "contact@lixium.dev"

DEPLOYMENT_REPO_OWNER=lixiumdev
DEPLOYMENT_REPO_NAME=deployment
DEPLOYMENT_REPO_URL=https://$GA_BOT_PAT@github.com/$DEPLOYMENT_REPO_OWNER/$DEPLOYMENT_REPO_NAME.git

git clone $DEPLOYMENT_REPO_URL
cd $DEPLOYMENT_REPO_NAME

DEPLOYMENT_BRANCH="$CLUSTER_NAME"

git switch -c $DEPLOYMENT_BRANCH --track origin/$DEPLOYMENT_BRANCH

WORKLOAD_FOLDER="./src/$CLUSTER_NAMESPACE/workloads/$SERVICE_NAME"

if [ ! -d "$WORKLOAD_FOLDER" ]; then
  echo "Could not find the workload folder for $SERVICE_NAME! (cluster: $CLUSTER_NAME, namespace: $CLUSTER_NAMESPACE)"
  exit 1
fi

cd $WORKLOAD_FOLDER

IMAGE="$REGISTRY_ADDRESS/$REGISTRY_NAME/$SERVICE_NAME:$GITHUB_SHA"
image=$IMAGE yq -i '.spec.template.spec.containers[0].image=env(image)' deployment.yml

git add deployment.yml

git commit -am "PIPELINE :: Image updated for \"$SERVICE_NAME\""

git pull --rebase origin $DEPLOYMENT_BRANCH
git push origin $DEPLOYMENT_BRANCH
