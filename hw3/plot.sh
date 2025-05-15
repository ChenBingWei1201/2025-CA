#!/bin/bash

python3 plot.py --name "l1i_size.csv" --row "L1-I size" --xlabel "Size (Bytes)" --ylabel "Latency (ms)" --title "Merge Sort Performance w/ L1-I$ size Config" --output_name "l1i_size.png" --ylimit 2.0
python3 plot.py --name "l1d_size.csv" --row "L1-D size" --xlabel "Size (Bytes)" --ylabel "Latency (ms)" --title "Merge Sort Performance w/ L1-D$ size Config" --output_name "l1d_size.png" --ylimit 2.0
python3 plot.py --name "l2_size.csv" --row "L2 size" --xlabel "Size (Bytes)" --ylabel "Latency (ms)" --title "Merge Sort Performance w/ L2$ size Config" --output_name "l2_size.png" --ylimit 3.5
python3 plot.py --name "l1i_assoc.csv" --row "L1-I assoc" --xlabel "Associativity" --ylabel "Latency (ms)" --title "Merge Sort Performance w/ L1-I$ assoc Config" --output_name "l1i_assoc.png" --ylimit 2.25
python3 plot.py --name "l1d_assoc.csv" --row "L1-D assoc" --xlabel "Associativity" --ylabel "Latency (ms)" --title "Merge Sort Performance w/ L1-D$ assoc Config" --output_name "l1d_assoc.png" --ylimit 2.0
python3 plot.py --name "l2_assoc.csv" --row "L2 assoc" --xlabel "Associativity" --ylabel "Latency (ms)" --title "Merge Sort Performance w/ L2$ assoc Config" --output_name "l2_assoc.png" --ylimit 2.0
