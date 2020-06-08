#!/bin/bash

echo "Am I alive server starting..."
node /am-i-alive.js &

echo "Stream-out server starting..."
node ${SCRIPT} ${SOCKET} /out.csv /dev/null ${PREFIX}

echo "Compressing files..."
gzip -f /out.csv && cp /out.csv.gz /dummy.triples.gz
#gzip -f /triples.nt

echo "Uploading files..."
node /upload.js ${NEXTCLOUD_DIRECTORY} /out.csv.gz /dummy.triples.gz
#/triples.nt.gz

echo "Done! Dreaming about triples..."
sleep infinity
