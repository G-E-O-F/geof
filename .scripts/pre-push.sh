echo "Testing PLANET"
cd planet
if ! mix test; then
  exit 1
fi
cd ..
