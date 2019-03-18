rm -rf placard/functions/app/public/docs
mkdir placard/functions/app/public/docs
mkdir -p placard/functions/app/config/docs

echo "〘Docs〙 GEOF.Planet"
cd planet
mix docs
cd ..
cp -r planet/doc placard/functions/app/public/docs/planet
cd placard/functions/app
mkdir -p config/docs/planet
cd ../../..

echo "〘Docs〙 GEOF.Shapes"
cd shapes
mix docs
cd ..
cp -r shapes/doc placard/functions/app/public/docs/shapes
cd placard/functions/app
mkdir -p config/docs/shapes
cd ../../..

echo "〘Docs〙 transforming docs HTML"
cd placard/functions
./scripts/transform-docs
cd ../..
