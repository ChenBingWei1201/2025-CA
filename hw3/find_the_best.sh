#!/bin/bash

# Define the allowed values (powers of 2)
sizes=(1kB 2kB 4kB 8kB 16kB 32kB 64kB 128kB)

# You can set your ISA type here
isa_type=32

# Loop over all combinations
for l1i_size in "${sizes[@]}"; do
  for l1d_size in "${sizes[@]}"; do
    for l2_size in "${sizes[@]}"; do
      # Construct the argument string
      args="--isa_type $isa_type --l1i_size $l1i_size --l1i_assoc 8 --l1d_size $l1d_size --l1d_assoc 8 --l2_size $l2_size --l2_assoc 8"
      echo "Running: make gem5 GEM5_ARGS=\"$args\""
      make gem5 GEM5_ARGS="$args"
      make save
    done
  done
done
