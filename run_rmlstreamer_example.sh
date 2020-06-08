#!/usr/bin/env bash

### stream-in
# example input file
export NEXTCLOUD_INPUT_FILE=https://cloud.ilabt.imec.be/index.php/s/22mNSjfagp2eeWQ/download

### stream-out
export NEXTCLOUD_DIRECTORY=examplerun

### Flink Taskmanager
export TASK_MANAGER_NUMBER_OF_TASK_SLOTS=4


### controller
export PARALLELISM=4

# avoid special characters ;)
export JOBNAME=example_mapping
export MAPPING_FILE=example_mapping.ttl

docker-compose -f docker-compose.yml -f docker-compose.rmlstreamer.yml up
