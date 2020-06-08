#!/usr/bin/env bash

echo "Start stream-in..."
echo "input file: ${NEXTCLOUD_INPUT_FILE}"
echo "upload dir: ${NEXTCLOUD_DIRECTORY}"
echo "id field:   ${SUFFIX}"
echo "port:       ${PORT}"
echo "delay:      ${DELAY}"
echo "duration:   ${DURATION}"

echo "Am I alive server starting..."
node /js/am-i-alive.js &

echo "Fetching input file ${NEXTCLOUD_INPUT_FILE}"
wget --output-document=data.gz ${NEXTCLOUD_INPUT_FILE} && \
gunzip data.gz

echo "Stream-in server starting..."
/rust/rstream-in --bind-address="0.0.0.0:${PORT}" --delay=${DELAY} --id-field=${SUFFIX} --input-file=/data --duration=${DURATION} --output-file=/in.csv

echo "Streaming input done. Compressing timings (in.csv)..."

gzip -f /in.csv

# put hostname in output file to avoid collisions
newname=in_$(hostname).csv.gz
mv /in.csv.gz /$newname

echo "Uploading timings..."
node /js/upload.js ${NEXTCLOUD_DIRECTORY} /$newname

# is this necessary?
echo "Done! Falling asleep."
sleep infinity
