echo "[Lint & add]: PLANET"
cd planet
mix format
cd ..
git add planet

echo "[Lint & add]: SIGHTGLASS"
cd sightglass
mix format
cd ..
git add sightglass

echo "[Lint & add]: THEATER"
cd theater
yarn precommit
cd ..
git add theater
