MIX_ENV=test

echo "Testing GEOF.Planet"
cd planet
mix deps.get --only test
mix test
mix coveralls
cd ..

echo "Testing GEOF.Shapes"
cd shapes
mix deps.get --only test
mix test
mix coveralls
cd ..
