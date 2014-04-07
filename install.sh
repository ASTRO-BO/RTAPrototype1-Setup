#!/usr/bin/env bash

declare -a repo_install=("PacketLib" "RTAtelem" "RTAConfig" "RTAtelemDemo")
declare -a repo=("RTAEBSimIce" "RTACoreIce1" "RTAMonitor")

trap exit err

for i in "${repo_install[@]}"
do
    cd $CTARTAREPOS/$i
    if [[ $1 == "clean" ]]
    then
        echo
        echo "Cleaning $i..."
        make clean
    fi
    echo
    echo "Building $i..."
    make -j5
    echo
    echo "Installing $i..."
    make install prefix=$CTARTA
done

for i in "${repo[@]}"
do
    cd $CTARTAREPOS/$i
    if [[ $1 == "clean" ]]
    then
        echo
        echo "Cleaning $i..."
        make clean
    fi
    echo
    echo "Building $i..."
    make -j5
done
