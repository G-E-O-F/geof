#! /bin/sh

. .scripts/config-ops.sh

echo "Deleting ${GCP_SERVICE_NAME}"

kubectl delete service ${GCP_SERVICE_NAME}

gcloud container clusters delete --zone=${GCP_CLUSTER_ZONE} ${GCP_CLUSTER_NAME}
