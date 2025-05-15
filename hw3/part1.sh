#!/bin/bash

# L1-I size
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make profile
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 2kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 4kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 8kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 16kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 32kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 64kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 128kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
mv "program_info.csv" "l1i_size.csv" && mv "l1i_size.csv" "part1/"

# L1-D size
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make profile
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 2kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 4kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 8kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 16kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 32kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 64kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 128kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make save
mv "program_info.csv" "l1d_size.csv" && mv "l1d_size.csv" "part1/"

# L2 size
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 1kB --l2_assoc 1" && make profile
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 2kB --l2_assoc 1" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 4kB --l2_assoc 1" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 8kB --l2_assoc 1" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 1" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 32kB --l2_assoc 1" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 64kB --l2_assoc 1" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 128kB --l2_assoc 1" && make save
mv "program_info.csv" "l2_size.csv" && mv "l2_size.csv" "part1/"

# L1-I associativity
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 1 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make profile
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 4 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 8 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
mv "program_info.csv" "l1i_assoc.csv" && mv "l1i_assoc.csv" "part1/"

# L1-D associativity
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 1 --l2_size 16kB --l2_assoc 2" && make profile
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 4 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 8 --l2_size 16kB --l2_assoc 2" && make save
mv "program_info.csv" "l1d_assoc.csv" && mv "l1d_assoc.csv" "part1/"

# L2 associativity
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 1" && make profile
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 2" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 4" && make save
make gem5 GEM5_ARGS="--isa_type 32 --l1i_size 1kB --l1i_assoc 2 --l1d_size 1kB --l1d_assoc 2 --l2_size 16kB --l2_assoc 8" && make save
mv "program_info.csv" "l2_assoc.csv" && mv "l2_assoc.csv" "part1/"
