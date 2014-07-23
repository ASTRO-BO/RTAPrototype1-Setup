#!/usr/bin/env bash

DELAY=3

function pskill {
	procs=$(ps -o pid,args | grep $1 | grep -v grep)
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

mkdir -p logs

## Ports 20000
cd RTAMonitor
echo "Starting RTAMonitor.."
nohup python RTAMonitorQt.py &> ../logs/monitor.log &
sleep $DELAY
cd ..

## Ports 10111, 10112, 10113
cd RTAViewCamera
echo "Starting RTAViewCamera 1.."
nohup python RTAViewCamera.py 1 --Ice.Config=config.server1 &> ../logs/viewcamera1.log &
echo "Starting RTAViewCamera 2.."
nohup python RTAViewCamera.py 2 --Ice.Config=config.server2 &> ../logs/viewcamera2.log &
echo "Starting RTAViewCamera 3.."
nohup python RTAViewCamera.py 3 --Ice.Config=config.server3 &> ../logs/viewcamera3.log &
sleep $DELAY
cd ..

## Ports 10101
cd RTAViewArray
echo "Starting RTAViewer.."
nohup python RTAViewer.py &> ../logs/viewer.log &
sleep $DELAY
cd ..

## Connects to RTAViewCamera
## Ports 50001, 50002, 50003
cd RTACoreIce
echo "Starting RTAWaveServer 1.."
nohup ./RTAWaveServer SmallTelescope --Ice.Config=config.server1 &> ../logs/wavewerver1.log &
echo "Starting RTAWaveServer 2.."
nohup ./RTAWaveServer MediumTelescope --Ice.Config=config.server2 &> ../logs/wavewerver2.log &
echo "Starting RTAWaveServer 3.."
nohup ./RTAWaveServer LargeTelescope --Ice.Config=config.server3 &> ../logs/wavewerver3.log &
sleep $DELAY
cd ..

## Connects to 3 RTAWaveServers
## Connects to RTAMonitor
## Connects to RTAViewer
cd RTACoreIce
echo "Starting RTAReceiver.."
nohup ./RTAReceiver_Ice $CTARTA/share/rtatelem/rta_fadc_all.stream &> ../logs/receiver.log &
sleep $DELAY
cd ..

## Connects to RTAReceiver
## Connects to RTAMonitor
cd RTAEBSimIce
echo "Starting RTAEBSim.."
nohup ./RTAEBSim $CTARTA/share/rtatelem/rta_fadc_all.stream $file 0 &> ../logs/ebsim.log &

echo "Pipeline started!"
