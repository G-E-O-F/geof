#!/usr/bin/env bash

OPWD=$PWD

echo "[sightglass] starting"
cd $OPWD/sightglass && elixir --detached -e "File.write! '.pid', :os.getpid" -S mix phoenix.server

PID0="$!"

sleep 4

PID1=`cat $OPWD/sightglass/.pid`
rm $OPWD/sightglass/.pid
echo "[sightglass] running at $PID1"

echo "[theater] starting"
cd $OPWD/theater && yarn start &
PID2="$!"
echo "[theater] running at $PID2"

trap "trap - SIGTERM && kill $PID0 $PID1 $PID2 $$" SIGINT SIGTERM EXIT
echo "[server] running at $$, waiting for SIGTERM/SIGINT/EXIT"

wait
