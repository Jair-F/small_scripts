#!/bin/bash

TEMP_FILE="/tmp/tmp_random_data.bin"

echo -n "Input File: "
read INPUT_FILE

echo -n "Num of KB to add(empty=4): "
read NUM_OF_KBYTES
if [ -z "$NUM_OF_KBYTES" ]; then
    NUM_OF_KBYTES="4"
fi

# removing trailing and leading ', "
INPUT_FILE="${INPUT_FILE//\"/}"
INPUT_FILE="${INPUT_FILE//\'/}"

OUTPUT_FILE="$INPUT_FILE.bin"

touch /tmp/tmp_random_data.bin

dd if=/dev/urandom of=$TEMP_FILE bs=1K count=$NUM_OF_KBYTES
cat $TEMP_FILE $orig_file > $OUTPUT_FILE
rm $TEMP_FILE
