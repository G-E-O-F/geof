MIX_ENV=test

echo "Testing PLANET"
cd planet
mix deps.get --only test
mix test
mix coveralls
cd ..

echo "Testing SHAPES"
cd shapes
mix deps.get --only test
mix test
mix coveralls
cd ..
