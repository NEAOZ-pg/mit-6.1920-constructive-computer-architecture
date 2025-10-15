#!/bin/bash

echo "Testing add"
./test.sh add32
timeout 1 ./top_bsv

echo "Testing and"
./test.sh and32
timeout 1 ./top_bsv

echo "Testing or"
./test.sh or32
timeout 1 ./top_bsv

echo "Testing sub"
./test.sh sub32
timeout 1 ./top_bsv

echo "Testing xor" 
./test.sh xor32
timeout 1 ./top_bsv

echo "Testing hello"
./test.sh hello32
timeout 1 ./top_bsv

echo "Testing mul"
./test.sh mul32
timeout 2 ./top_bsv

echo "Testing reverse"
./test.sh reverse32
timeout 1 ./top_bsv

echo "Testing thelie"
./test.sh thelie32
timeout 10 ./top_bsv

echo "Testing thuemorse"
./test.sh thuemorse32
timeout 10 ./top_bsv

echo "Testing matmul"
./test.sh matmul32
timeout 60 ./top_bsv

