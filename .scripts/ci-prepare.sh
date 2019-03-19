#! /bin/sh

gcloud config set project geof-io

if [ ! -f placard/functions/config/gcp-key.json ]
then
  if [ -z ${GCP_KEY+x} ]
  then
    echo "〘Deploy〙 quitting: no GCP key source found"
    exit 1
  else
    echo "〘Deploy〙 writing GCP key file from environment"
    mkdir -p placard/functions/config
    printf '%s' $GCP_KEY > placard/functions/config/gcp-key.json
  fi
else
  echo "〘Deploy〙 GCP key file present"
fi
GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f placard/functions/config/gcp-key.json)
gcloud auth activate-service-account --key-file placard/functions/config/gcp-key.json

if [ ! -f placard/functions/config/twitter-key.json ]
then
  if [ -z ${TWITTER_KEY+x} ]
  then
    echo "〘Deploy〙 no Twitter key source found"
  else
    echo "〘Deploy〙 writing Twitter key file from environment"
    mkdir -p placard/functions/config
    printf '%s' $TWITTER_KEY > placard/functions/config/twitter-key.json
  fi
else
  echo "〘Deploy〙 Twitter key file present"
fi

if [ ! -f sightglass/config/prod.secret.exs ]
then
  if [ -z ${SIGHTGLASS_PROD_CONFIG+x} ]
  then
    echo "〘Deploy〙 no GEOF.Sightglass prod config found"
  else
    echo "〘Deploy〙 writing GEOF.Sightglass prod config from environment"
    printf '%s' $SIGHTGLASS_PROD_CONFIG > sightglass/config/prod.secret.exs
  fi
else
  echo "〘Deploy〙 GEOF.Sightglass prod config present"
fi


cd placard/functions
yarn install --non-interactive
cd ../..

cd planet
mix deps.get
cd ..

cd shapes
mix deps.get
cd ..

cd sightglass
mix deps.get
cd ..
