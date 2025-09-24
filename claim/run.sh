#!/bin/bash

arg="$1"

# Set the folders
BASELINE_DIR="embench-baseline"
BLAST_DIR="embench-blast"
SULFUR_DIR="embench-blast-sulfur"

echo "Running LmBench................"

echo "Creating a 50MB file filled with zeros: 'largefile'..."
dd if=/dev/zero of=largefile bs=50M count=1
echo "File 'largefile' created."

echo
echo "Measuring system call latency: NULL"
./lat_syscall null

echo
echo "Measuring system call latency: READ on 'largefile'..."
./lat_syscall read largefile

echo
echo "Measuring system call latency: WRITE on 'largefile'..."
./lat_syscall write largefile

echo
echo "Measuring system call latency: STAT on 'largefile'..."
./lat_syscall stat largefile

echo
echo "Measuring signal installation latency..."
./lat_sig install largefile

echo
echo "Measuring context switch latency with 6 processes..."
./lat_ctx 6

echo
echo "Measuring page fault latency with 'largefile'..."
./lat_pagefault largefile

echo
echo "All latency tests completed."

echo "Running Embench...................."

chmod a+x /usr/bin/$BASELINE_DIR/*
chmod a+x /usr/bin/$BLAST_DIR/*
chmod a+x /usr/bin/$SULFUR_DIR/*

if [ "$arg" = "baseline" ]; then
    # Loop through each .bin file in the baseline directory
    for baseline_bin in "$BASELINE_DIR"/*.bin; do
        # Get the base name of the binary 
        base_name=$(basename "$baseline_bin" .bin)

        # Construct the corresponding blast binary name
        blast_bin="$BLAST_DIR/${base_name}-bl-sfi.bin"

        echo "Running $base_name:"

        # Run baseline binary and measure real time
        echo -n "  Baseline time: "
        time -f "%e" ./"$baseline_bin" > /dev/null 

        # Run blast binary and measure real time
        echo -n "  Blast time: "
        time -f "%e" ./"$blast_bin" > /dev/null 

        echo ""
    done

elif [ "$arg" = "sulfur" ]; then 
    # Loop through each .bin file in the baseline directory
    for baseline_bin in "$BASELINE_DIR"/*.bin; do
        # Get the base name of the binary 
        base_name=$(basename "$baseline_bin" .bin)

        # Construct the corresponding blast_sulfur_bin binary name
        blast_sulfur_bin="$SULFUR_DIR/${base_name}-bl-sfi.bin"

        echo "Running $base_name:"

        # Run baseline binary and measure real time
        echo -n "  Baseline time: "
        time -f "%e" ./"$baseline_bin" > /dev/null 

        # Run blast-sulfur binary and measure real time
        echo -n "  Blast-Sulfur time: "
        time -f "%e" ./"$blast_sulfur_bin" > /dev/null

        echo ""
    done


else 
    echo "Provide argument "baseline" or "sulfur" based on the build type"
fi
