rm -rf placard/functions/app/public/docs
mkdir placard/functions/app/public/docs

echo "Generating docs for GEOF.Planet"
cd planet
mix docs
cd ..
cp -r planet/doc placard/functions/app/public/docs/planet

echo "Generating docs for GEOF.Shapes"
cd shapes
mix docs
cd ..
cp -r shapes/doc placard/functions/app/public/docs/shapes
