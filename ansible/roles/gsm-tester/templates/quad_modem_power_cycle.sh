#!/bin/sh
set -ex

locations="$(uhubctl -n 1d50:4002 | grep "Current status for hub" | awk '{print $5}')"
for l in $locations; do
	uhubctl -p 1,2,3,4,5,6 -a 0 -n 1d50:4002 -l $l
done
# give a lot of time to discharge capacitors on the board
sleep 5
for l in $locations; do
	uhubctl -p 1,2,3,4,5,6 -a 1 -n 1d50:4002 -l $l
done
uhubctl
