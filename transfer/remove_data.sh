#!/bin/bash

if [ -z "$1" ]; then
    echo -n "Input File: "
    read INPUT_FILE

    echo -n "Num of KB to add(empty=4): "
    read NUM_OF_KBYTES
else
    INPUT_FILE=$1
    NUM_OF_KBYTES=$2
fi

if [ -z "$NUM_OF_KBYTES" ]; then
    NUM_OF_KBYTES="4"

    echo "going with default bytes to remove: $NUM_OF_KBYTES kb"
fi

# removing trailing and leading ', "
INPUT_FILE="${INPUT_FILE//\"/}"
INPUT_FILE="${INPUT_FILE//\'/}"

# remove .bin at the end
OUTPUT_FILE="${INPUT_FILE%.bin}"

dd if=$INPUT_FILE of=$OUTPUT_FILE bs=1K skip=$NUM_OF_KBYTES
