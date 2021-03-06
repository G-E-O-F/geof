#! /bin/sh

GCP_KEY_FILE=placard/functions/config/gcp-key.json

if [ ! -f $GCP_KEY_FILE ]
then
  if [ -z ${GCP_KEY+x} ]
  then
    echo "〘Deploy〙 quitting: no GCP key source found"
    exit 1
  else
    echo "〘Deploy〙 writing GCP key file from environment"
    mkdir -p placard/functions/config
    echo $GCP_KEY | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' > $GCP_KEY_FILE
  fi
else
  echo "〘Deploy〙 GCP key file present"
fi

TWITTER_KEY_FILE=placard/functions/config/twitter-key.json

if [ ! -f $TWITTER_KEY_FILE ]
then
  if [ -z ${TWITTER_KEY+x} ]
  then
    echo "〘Deploy〙 no Twitter key source found"
  else
    echo "〘Deploy〙 writing Twitter key file from environment"
    mkdir -p placard/functions/config
    echo $TWITTER_KEY > $TWITTER_KEY_FILE
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
    echo $SIGHTGLASS_PROD_CONFIG > sightglass/config/prod.secret.exs
  fi
else
  echo "〘Deploy〙 GEOF.Sightglass prod config present"
fi

export GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f $GCP_KEY_FILE)
gcloud auth activate-service-account --key-file=$GCP_KEY_FILE

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
