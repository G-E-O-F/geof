echo "〘Test〙 GEOF.Planet"
cd planet
if ! mix test; then
  exit 1
fi
cd ..

echo "〘Test〙 GEOF.Shapes"
cd shapes
if ! mix test; then
  exit 1
fi
cd ..

echo "〘Test〙 GEOF.Climate"
cd climate
if ! mix test; then
  exit 1
fi
cd ..

echo "〘Test〙 GEOF.Sightglass"
cd sightglass
if ! mix test; then
  exit 1
fi
cd ..
