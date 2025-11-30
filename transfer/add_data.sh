#!/bin/bash

echo "Argument 1: $1"
echo "Argument 2: $2"

TEMP_FILE="/tmp/tmp_random_data.bin"

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
    echo "going with default bytes to add: $NUM_OF_KBYTES kb"
else
    echo "set bytes to add to : $NUM_OF_KBYTES kb"
fi

# removing trailing and leading ', "
INPUT_FILE="${INPUT_FILE//\"/}"
INPUT_FILE="${INPUT_FILE//\'/}"

OUTPUT_FILE="$INPUT_FILE.bin"

touch /tmp/tmp_random_data.bin

dd if=/dev/urandom of=$TEMP_FILE bs=1K count=$NUM_OF_KBYTES
cat $TEMP_FILE $INPUT_FILE > $OUTPUT_FILE
rm $TEMP_FILE
