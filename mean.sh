#!/usr/bin/env bash

cat $CTARTA/var/log/rta/ebsim.log | grep throughput | cut -d ' ' -f2 | cut -d . -f1 | cut -d'M' -f1 | tail -n+5 | awk '{sum+=$1} END { print "Average EBSim = ",sum/NR}'

cat $CTARTA/var/log/rta/receiver.log | grep throughput | cut -d ' ' -f2 | cut -d . -f1 | cut -d'M' -f1 | tail -n+5 | awk '{sum+=$1} END { print "Average receiver = ",sum/NR}'
