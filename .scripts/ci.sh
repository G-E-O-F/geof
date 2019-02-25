echo "Testing PLANET"
cd planet
mix deps.get
mix test
cd ..

echo "Testing SHAPES"
cd shapes
mix deps.get
mix test
cd ..
