#!/bin/bash

if [ ! -f reader_writer.c ]; then
    echo "Please navigate to the application folder first!!!"
    exit 1
fi

gcc reader_writer.c -o reader_writer
gcc converter.c -o converter

echo 1
./reader_writer "../tests/inputs/input1_1.txt" "../tests/inputs/input1_2.txt" "../tests/outputs/two_pipes_independent_unnamed/output1.txt" & sleep 0.5 && ./converter

echo 2
./reader_writer "../tests/inputs/input2_1.txt" "../tests/inputs/input2_2.txt" "../tests/outputs/two_pipes_independent_unnamed/output2.txt" & sleep 0.5 && ./converter

echo 3
./reader_writer "../tests/inputs/input3_1.txt" "../tests/inputs/input3_2.txt" "../tests/outputs/two_pipes_independent_unnamed/output3.txt" & sleep 0.5 && ./converter

echo 4
./reader_writer "../tests/inputs/input4_1.txt" "../tests/inputs/input4_2.txt" "../tests/outputs/two_pipes_independent_unnamed/output4.txt" & sleep 0.5 && ./converter

echo 5
./reader_writer "../tests/inputs/input5_1.txt" "../tests/inputs/input5_2.txt" "../tests/outputs/two_pipes_independent_unnamed/output5.txt" & sleep 0.5 && ./converter

rm reader_writer
rm converter