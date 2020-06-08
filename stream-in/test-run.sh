#!/usr/bin/env bash

# provide NEXTCLOUD_USERNAME and NEXTCLOUD_PASSWORD in .env file
source .env
echo "$NEXTCLOUD_USERNAME"
export NEXTCLOUD_URL=https://cloud.ilabt.imec.be/remote.php/webdav/

export NEXTCLOUD_INPUT_FILE=https://cloud.ilabt.imec.be/index.php/s/CkZAikeq2TpzsjY/download?path=data/1000_tweets.gz
export NEXTCLOUD_DIRECTORY=tmp/testinputrun
export PORT=5005
export DELAY=500000000
export DURATION=20
export SUFFIX=id_str

./run.sh
