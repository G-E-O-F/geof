echo "〘Lint & Add〙 GEOF.Planet"
cd planet
mix format
cd ..
git add planet

echo "〘Lint & Add〙 GEOF.Shapes"
cd shapes
mix format
cd ..
git add shapes

echo "〘Lint & Add〙 GEOF.Climate"
cd climate
mix format
cd ..
git add climate

echo "〘Lint & Add〙 GEOF.Sightglass"
cd sightglass
mix format
cd ..
git add sightglass

echo "〘Lint & Add〙 GEOF.Theater"
cd theater
if ! yarn precommit; then
  exit 1
fi
cd ..
git add theater

echo "〘Lint & Add〙 GEOF.Placard"
cd placard/functions
if ! yarn precommit; then
  exit 1
fi
cd ../..
