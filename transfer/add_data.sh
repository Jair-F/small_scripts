#!/bin/bash

TEMP_FILE="/tmp/tmp_random_data.bin"
MAGIC_BITS_OFFSET_BYTES=32

appendRandomData() {
    local fileName="$1"
    local numOfBytes=$2
    dd if=/dev/urandom bs=1 count=$numOfBytes status=none >> $fileName
}

if [ -z "$1" ]; then
    echo -n "Input File: "
    read INPUT_FILE < /dev/tty

    echo -n "Num of KB to add(empty=4, max=99): "
    read NUM_OF_KBYTES < /dev/tty
else
    INPUT_FILE=$1
    NUM_OF_KBYTES=$2
fi

if [ -z "$NUM_OF_KBYTES" ] || [ $NUM_OF_KBYTES -lt 1 ]; then
    NUM_OF_KBYTES="4"
    echo "going with default bytes to add: $NUM_OF_KBYTES kb"
fi

if [ $NUM_OF_KBYTES -gt 99 ]; then
    NUM_OF_KBYTES="99"
fi
echo "set bytes to add to : $NUM_OF_KBYTES kb"
if [ "$NUM_OF_KBYTES" -lt 10 ] && [ ${#NUM_OF_KBYTES} -lt 2 ]; then
    NUM_OF_KBYTES="0$NUM_OF_KBYTES"
fi

# removing trailing and leading ', "
INPUT_FILE="${INPUT_FILE//\"/}"
INPUT_FILE="${INPUT_FILE//\'/}"
OUTPUT_FILE="$INPUT_FILE.bin"

touch $TEMP_FILE
truncate -s 0 $TEMP_FILE

appendRandomData "$TEMP_FILE" "$MAGIC_BITS_OFFSET_BYTES"

echo "$NUM_OF_KBYTES" >> $TEMP_FILE

appendRandomData "$TEMP_FILE" $(( $NUM_OF_KBYTES * 1024 ))
cat $TEMP_FILE $INPUT_FILE > $OUTPUT_FILE
rm $TEMP_FILE
