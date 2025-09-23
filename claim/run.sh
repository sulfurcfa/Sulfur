#!/bin/bash

arg="$1"

cd ../artifact

if [ "$arg" = "baseline" ]; then
    echo "Building baseline code. THIS MAY TAKE TIME."
    cd build
    sudo make  PYTHON=python2 all -j$(nproc)

elif [ "$arg" = "sulfur" ]; then
    echo "Building sulfur code. THIS MAY TAKE TIME."
    cd linux
    scripts/config --enable CONFIG_ENABLE_SLAM
    scripts/config --enable CONFIG_ARM64_BTI
    scripts/config --enable CONFIG_ARM64_BTI_PTR_AUTH_KERNEL
    scripts/config --enable CONFIG_ARM64_BTI_KERNEL
    cd ../build 
    sudo make  PYTHON=python2 all -j$(nproc)
    
else
    echo "Provide one of the two arguments:"
    echo "  baseline : for baseline measurement"
    echo "  sulfur   : for the sulfur implementation measurement"
    exit 1
fi

# Copying Benchmarks to Target File System

cd ..

echo "Copy Lmbench binaries in Fvp"
cp Lmbench/bin/* out-br/target/usr/bin

echo "Copy Embench binaries in Fvp"
cp -r Embench/* out-br/target/usr/bin

echo "Copy run.sh script"
cp run.sh out-br/target/usr/bin

echo "Building the filesystem with the changes and then runnig FVP again"

cd build
sudo make  PYTHON=python2  run -j$(nproc)
