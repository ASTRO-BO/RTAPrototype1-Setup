#!/usr/bin/env bash

declare -a repo_install=("PacketLib" "RTAtelem" "RTAConfig" "RTAtelemDemo")
declare -a repo=("RTAEBSimIce" "RTACoreIce" "RTAMonitor" "RTAViewArray" "RTAViewCamera")

trap exit err

for i in "${repo_install[@]}" "${repo[@]}"
do
    echo
    echo "Downloading $i..."
    cd $CTARTAREPOS/$i && git fetch --all && git rebase origin/master
done
