rm -rf placard/functions/app/public/docs
mkdir placard/functions/app/public/docs

echo "[Docs] GEOF.Planet"
cd planet
mix docs
cd ..
cp -r planet/doc placard/functions/app/public/docs/planet

echo "[Docs] GEOF.Shapes"
cd shapes
mix docs
cd ..
cp -r shapes/doc placard/functions/app/public/docs/shapes
