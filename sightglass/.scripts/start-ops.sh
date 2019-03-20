#! /bin/sh

. .scripts/config-ops.sh

# Making sure gcloud is ready

gcloud components update
gcloud components install kubectl
gcloud config set project ${GCP_PROJECT_NAME}

# Submit build

gcloud builds submit --substitutions=_TAG=start .

# Create cluster

gcloud container clusters create ${GCP_CLUSTER_NAME} --num-nodes=1 --zone=${GCP_CLUSTER_ZONE}
gcloud container clusters get-credentials --zone=${GCP_CLUSTER_ZONE} ${GCP_CLUSTER_NAME}
gcloud config set container/cluster ${GCP_CLUSTER_NAME}

# Deploy to cluster

kubectl run ${GCP_SERVICE_NAME} --image=gcr.io/${GCP_PROJECT_NAME}/${GCP_SERVICE_NAME}:start --port 8080
kubectl expose deployment ${GCP_SERVICE_NAME} --type=LoadBalancer --port 80 --target-port 8080
