#! /bin/sh

./.scripts/ci-prepare.sh

apt-get install -y kubectl
gcloud config set project geof-io
gcloud info --run-diagnostics

echo "〘Deploy〙 GEOF.Sightglass"
SIGHTGLASS_VERSION=$(git log --pretty=format:'%h' -n 1)

cd sightglass
MIX_ENV=prod mix release --env=prod
gcloud builds submit --substitutions=_TAG=$SIGHTGLASS_VERSION .
kubectl set image deployment/sightglass sightglass=gcr.io/geof-io/sightglass:$SIGHTGLASS_VERSION
cd ..

./.scripts/docs.sh

echo "〘Deploy〙 uploading docs to storage"
gsutil rm -rf gs://geof-io.appspot.com/docs
gsutil cp -r placard/functions/app/config/docs gs://geof-io.appspot.com/docs

echo "〘Deploy〙 GEOF.Placard"

cd placard
firebase deploy

cd functions
./scripts/tweet-on-deploy

cd ../..
