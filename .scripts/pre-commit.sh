echo "[Lint & add]: PLANET"
cd planet
mix format
if ! mix test; then
  exit 1
fi
cd ..
git add planet

echo "[Lint & add]: SHAPES"
cd shapes
mix format
if ! mix test; then
  exit 1
fi
cd ..
git add shapes

echo "[Lint & add]: SIGHTGLASS"
cd sightglass
mix format
cd ..
git add sightglass

echo "[Lint & add]: THEATER"
cd theater
if ! yarn precommit; then
  exit 1
fi
cd ..
git add theater

echo "[Lint & add]: PLACARD"
cd placard/functions
if ! yarn precommit; then
  exit 1
fi
cd ../..
