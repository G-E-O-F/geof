echo "[Lint & add]: GEOF.Planet"
cd planet
mix format
cd ..
git add planet

echo "[Lint & add]: GEOF.Shapes"
cd shapes
mix format
cd ..
git add shapes

echo "[Lint & add]: GEOF.Sightglass"
cd sightglass
mix format
cd ..
git add sightglass

echo "[Lint & add]: GEOF.Theater"
cd theater
if ! yarn precommit; then
  exit 1
fi
cd ..
git add theater

echo "[Lint & add]: GEOF.Placard"
cd placard/functions
if ! yarn precommit; then
  exit 1
fi
cd ../..
