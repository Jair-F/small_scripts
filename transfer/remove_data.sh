#!/bin/bash

MAGIC_BITS_OFFSET_BYTES=32

if [ -z "$1" ]; then
    echo -n "Input File: "
    read INPUT_FILE < /dev/tty
else
    INPUT_FILE=$1
fi

# removing trailing and leading ', "
INPUT_FILE="${INPUT_FILE//\"/}"
INPUT_FILE="${INPUT_FILE//\'/}"

NUM_OF_KBYTES=$(dd if=$INPUT_FILE bs=1 skip=32 count=2 status=none | tr -dc '0-9')

if [ -z "$NUM_OF_KBYTES" ]; then
    echo "Error: Could not find a valid number at offset 32"
    exit 1
fi

TOTAL_SKIP_BYTES=$(( (NUM_OF_KBYTES * 1024) + MAGIC_BITS_OFFSET_BYTES + 3 ))

# remove .bin at the end
OUTPUT_FILE="${INPUT_FILE%.bin}"

dd if=$INPUT_FILE of=$OUTPUT_FILE bs=1 skip=$TOTAL_SKIP_BYTES
