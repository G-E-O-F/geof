if [ ! -f placard/functions/config/gcp-key.json ]
then
  if [ -z ${GCP_KEY+x} ]
  then
    echo "〘Deploy〙 quitting: no key source found"
    exit 1
  else
    echo "〘Deploy〙 writing key file from environment"
    mkdir -p placard/functions/config
    echo "$GCP_KEY" >> placard/functions/config/gcp-key.json
  fi
else
  echo "〘Deploy〙 key file present"
fi
GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f placard/functions/config/gcp-key.json)
gcloud auth activate-service-account --key-file placard/functions/config/gcp-key.json

./.scripts/docs.sh
echo "〘Deploy〙 uploading docs to storage"
gsutil rm -rf gs://geof-io.appspot.com/docs
gsutil cp -r placard/functions/app/config/docs gs://geof-io.appspot.com/docs

echo "〘Deploy〙 GEOF.Placard"
cd placard/functions
yarn install
cd ..
firebase deploy
cd ..
