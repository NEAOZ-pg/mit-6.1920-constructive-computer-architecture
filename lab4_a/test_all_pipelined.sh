#!/bin/bash

echo "Testing add"
./test.sh add32
timeout 5 ./top_pipelined

echo "Testing and"
./test.sh and32
timeout 5 ./top_pipelined

echo "Testing or"
./test.sh or32
timeout 5 ./top_pipelined

echo "Testing sub"
./test.sh sub32
timeout 5 ./top_pipelined

echo "Testing xor" 
./test.sh xor32
timeout 5 ./top_pipelined

echo "Testing hello"
./test.sh hello32
timeout 5 ./top_pipelined

echo "Testing mul"
./test.sh mul32
timeout 5 ./top_pipelined

echo "Testing reverse"
./test.sh reverse32
timeout 15 ./top_pipelined

echo "Testing thelie"
./test.sh thelie32
timeout 25 ./top_pipelined

echo "Testing thuemorse"
./test.sh thuemorse32
timeout 25 ./top_pipelined

echo "Testing multicore32"
./testMC.sh multicore32
timeout 120 ./top_pipelined


echo "Testing matmulmulti32"
./testMC.sh matmulmulti32
timeout 120 ./top_pipelined


echo "Testing buffer32"
./testMC.sh buffer32
timeout 120 ./top_pipelined



