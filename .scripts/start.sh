#!/usr/bin/env bash

OPWD=$PWD

echo "〘GEOF.Sightglass〙 starting"
cd $OPWD/sightglass && elixir --detached -e "File.write! '.pid', :os.getpid" -S mix phoenix.server

PID0="$!"

sleep 4

PID1=`cat $OPWD/sightglass/.pid`
rm $OPWD/sightglass/.pid
echo "〘GEOF.Sightglass〙 running at $PID1"

echo "〘GEOF.Theater〙 starting"
cd $OPWD/theater && yarn start &
PID2="$!"
echo "〘GEOF.Theater〙 running at $PID2"

trap "trap - SIGTERM && kill $PID0 $PID1 $PID2 $$" SIGINT SIGTERM EXIT
echo "〘GEOF.Sightglass〙 running at $$, waiting for SIGTERM/SIGINT/EXIT"

wait
