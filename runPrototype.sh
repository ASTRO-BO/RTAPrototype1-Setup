#!/usr/bin/env bash

DELAY=3
LOGDIR=$CTARTA/var/log/rta
CONFIGDIR=$CTARTA/share

function pskill {
	procs=$(ps -xo pid,args | grep $1 | grep -v grep)
	while read -r line; do
		if [[ -n $line ]]
		then
			pname=$(echo $line | cut -d' ' -f2-)
			pid=$(echo $line | cut -d' ' -f1)
			echo "Killing pid $pid: $pname"
			kill -9 $pid
		fi
	done <<< "$procs"
}

if [[ $1 == "-k" ]]
then
	pskill RTAMonitorQt
	pskill RTAWaveServer
	pskill RTAViewCamera
	pskill RTAViewer
	pskill RTAReceiver
	pskill RTAEBSim
	exit
fi

# Expects a .raw input file for ebsim
if [[ ! -f $1 ]]
then
	echo "No simulator input file provided. Plear run:"
	echo "./runPrototype.sh input.raw"
	exit
else
	# get absolute path
	case $1 in
	  /*) file=$1;;
	  *) file=$PWD/$1;;
	esac
	echo "Using input file $file.."
fi

mkdir -p $CTARTA/var/log/rta

## Ports 20000
echo "Starting RTAMonitor.."
nohup python RTAMonitorQt.py --Ice.Config=$CONFIGDIR/monitor/config.monitor &> $LOGDIR/monitor.log &
sleep $DELAY

## Ports 10111, 10112, 10113
echo "Starting RTAViewCamera 1.."
nohup python RTAViewCamera.py 1 --Ice.Config=$CONFIGDIR/viewcamera/config.server1 &> $LOGDIR/viewcamera1.log &
echo "Starting RTAViewCamera 2.."
nohup python RTAViewCamera.py 2 --Ice.Config=$CONFIGDIR/viewcamera/config.server2 &> $LOGDIR/viewcamera2.log &
echo "Starting RTAViewCamera 3.."
nohup python RTAViewCamera.py 3 --Ice.Config=$CONFIGDIR/viewcamera/config.server3 &> $LOGDIR/viewcamera3.log &
sleep $DELAY

## Ports 10101
echo "Starting RTAViewer.."
nohup python RTAViewer.py --Ice.Config=$CONFIGDIR/viewer/config.server &> $LOGDIR/viewer.log &
sleep $DELAY

## Connects to RTAViewCamera
## Ports 50001, 50002, 50003
echo "Starting RTAWaveServer 1.."
nohup ./RTAWaveServer --Ice.Config=$CONFIGDIR/core/waveserver/config.server1 LargeTelescope &> $LOGDIR/waveserver1.log &
echo "Starting RTAWaveServer 2.."
nohup ./RTAWaveServer --Ice.Config=$CONFIGDIR/core/waveserver/config.server2 MediumTelescope &> $LOGDIR/waveserver2.log &
echo "Starting RTAWaveServer 3.."
nohup ./RTAWaveServer --Ice.Config=$CONFIGDIR/core/waveserver/config.server3 SmallTelescope &> $LOGDIR/waveserver3.log &
sleep $DELAY

## Connects to 3 RTAWaveServers
## Connects to RTAMonitor
## Connects to RTAViewer
echo "Starting RTAReceiver.."
nohup ./RTAReceiver_Ice $CTARTA/share/rtatelem/rta_fadc_all.stream --Ice.Config=$CONFIGDIR/core/receiver/config.receiverNoStorm &> $LOGDIR/receiver.log &
sleep $DELAY

## Connects to RTAReceiver
## Connects to RTAMonitor
echo "Starting RTAEBSim.."
nohup ./RTAEBSim $CTARTA/share/rtatelem/rta_fadc_all.stream $file 0 --Ice.Config=$CONFIGDIR/ebsim/config.sim &> $LOGDIR/ebsim.log &

echo "Pipeline started!"
