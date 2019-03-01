MIX_ENV=test

echo "Generating docs for GEOF.Planet"
cd planet
mix docs
cd ..

echo "Generating docs for GEOF.Shapes"
cd shapes
mix docs
cd ..
