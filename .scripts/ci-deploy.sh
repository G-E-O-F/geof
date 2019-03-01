echo "[Deploy] GEOF.Placard"
cd placard/functions
yarn install
cd ..
firebase deploy
cd ..
