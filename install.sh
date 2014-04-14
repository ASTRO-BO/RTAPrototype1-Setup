#!/usr/bin/env bash

declare -a repo_install=("PacketLib" "RTAtelem" "RTAConfig" "RTAtelemDemo")
declare -a repo=("RTAEBSimIce" "RTACoreIce" "RTAMonitor")

trap exit err

for i in "${repo_install[@]}"
do
	pushd $PWD
    cd $i
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
	popd
done

for i in "${repo[@]}"
do
	pushd $PWD
    cd $i
    if [[ $1 == "clean" ]]
    then
        echo
        echo "Cleaning $i..."
        make clean
    fi
    echo
    echo "Building $i..."
    make -j5
	popd
done
