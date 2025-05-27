make g++_final
make gem5_public ARGS=P5
make testbench_public

echo "====================" >> score.txt
echo "gem5_args.conf:" >> score.txt
cat gem5_args.conf >> score.txt
echo "score_public output:" >> score.txt
make score_public >> score.txt
