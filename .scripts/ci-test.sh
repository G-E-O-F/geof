MIX_ENV=test

echo "[Test] GEOF.Planet"
cd planet
mix deps.get --only test
mix test
mix coveralls
cd ..

echo "[Test] GEOF.Shapes"
cd shapes
mix deps.get --only test
mix test
mix coveralls
cd ..
