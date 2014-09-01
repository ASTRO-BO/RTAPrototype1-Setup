#!/usr/bin/env bash

trap exit ERR

NTHREADS=5

declare -a cmake_repoinstall=("libQLBase")

if [[ $1 == "minimal" ]]
then
	declare -a repo_install=("PacketLib" "RTAtelem" "RTAConfig" "RTAEBSimIce" "RTACoreIce")
elif [[ $1 == "nogui" ]]
then
	declare -a repo_install=("PacketLib" "RTAtelem" "RTAConfig" "RTAtelemDemo" "RTAEBSimIce" "RTACoreIce")
else
	declare -a repo_install=("PacketLib" "RTAtelem" "RTAConfig" "RTAtelemDemo" "RTAEBSimIce" "RTACoreIce" "RTAMonitor" "RTAViewArray" "RTAViewCamera")
fi

for i in "${cmake_repoinstall[@]}"
do
    pushd $PWD
    cd $i
    if [[ $1 == "clean" ]]
    then
        echo
        echo "Cleaning $i..."
        rm -rf build
    else
        echo
        echo "Building $i..."
        mkdir -p build/$i
        cd build/
        cmake -DCMAKE_BUILD_TYPE=Debug \
          -DCMAKE_INSTALL_PREFIX:PATH=$CTARTA \
          -DBoost_NO_BOOST_CMAKE=ON \
          ..
        make VERBOSE=1 -j$NTHREADS
        echo "Installing $1..."
        make install
    fi
	popd
done

for i in "${repo_install[@]}"
do
	pushd $PWD
    cd $i
    if [[ $1 == "clean" ]]
    then
        echo
        echo "Cleaning $i..."
        make clean
    else
        echo
        echo "Building $i..."
        make -j$NTHREADS
        echo
        echo "Installing $i..."
        make install prefix=$CTARTA
    fi
	popd
done

if [[ $1 != "clean" ]]
then
	cp -p runPrototype.sh $CTARTA/bin
	cp -p runPrototypeCommandLine.sh $CTARTA/bin
fi
