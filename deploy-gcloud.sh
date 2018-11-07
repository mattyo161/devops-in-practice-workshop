#!/usr/bin/env bash
set -xe
# kubectl apply -f kubernetes-gcloud/mysql.yml
# kubectl apply -f kubernetes-gcloud/web.yml

echo "Deploying pet-db..."
kubectl apply -f kubernetes-gcloud/mysql.yml --namespace default

IMAGE_VERSION=${GO_PIPELINE_LABEL:-latest}
PROJECT_ID=${GCLOUD_PROJECT_ID:-devops-workshop-221503}
echo "Deploying pet-web image version: $IMAGE_VERSION"

cat kubernetes-gcloud/web.yml | sed "s/\(image: \).*$/\1us.gcr.io\/$PROJECT_ID\/pet-app:$IMAGE_VERSION/" | kubectl apply -f - --namespace default
