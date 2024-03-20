#!/bin/bash

if [ ! -f two_pipes_unnamed.c ]; then
    echo "Please navigate to the application folder first!!!"
    exit 1
fi

gcc two_pipes_unnamed.c -o two_pipes_unnamed

echo 1
./two_pipes_unnamed "../tests/inputs/input1_1.txt" "../tests/inputs/input1_2.txt" "../tests/outputs/two_pipes_unnamed/output1.txt"

echo 2
./two_pipes_unnamed "../tests/inputs/input2_1.txt" "../tests/inputs/input2_2.txt" "../tests/outputs/two_pipes_unnamed/output2.txt"

echo 3
./two_pipes_unnamed "../tests/inputs/input3_1.txt" "../tests/inputs/input3_2.txt" "../tests/outputs/two_pipes_unnamed/output3.txt"

echo 4
./two_pipes_unnamed "../tests/inputs/input4_1.txt" "../tests/inputs/input4_2.txt" "../tests/outputs/two_pipes_unnamed/output4.txt"

echo 5
./two_pipes_unnamed "../tests/inputs/input5_1.txt" "../tests/inputs/input5_2.txt" "../tests/outputs/two_pipes_unnamed/output5.txt"

rm two_pipes_unnamed