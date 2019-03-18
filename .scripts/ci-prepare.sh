#! /bin/sh

yarn cache clean

cd placard/functions
yarn install --no-lockfile --non-interactive
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
