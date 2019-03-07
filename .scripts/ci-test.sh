MIX_ENV=test

echo "〘Test & Coverage〙 GEOF.Planet"
cd planet
mix deps.get --only test
mix test
mix coveralls
cd ..

echo "〘Test & Coverage〙 GEOF.Shapes"
cd shapes
mix deps.get --only test
mix test
mix coveralls
cd ..
