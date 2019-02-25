echo "Testing PLANET"
cd planet
mix deps.get --only test
mix test
cd ..

echo "Testing SHAPES"
cd shapes
mix deps.get --only test
mix test
cd ..
