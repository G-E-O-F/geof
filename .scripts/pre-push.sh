echo "Testing GEOF.Planet"
cd planet
if ! mix test; then
  exit 1
fi
cd ..

echo "Testing GEOF.Shapes"
cd shapes
if ! mix test; then
  exit 1
fi
cd ..
