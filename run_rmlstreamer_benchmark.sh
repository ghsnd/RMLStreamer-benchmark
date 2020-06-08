#!/usr/bin/env bash

######################
# 'Fixed' config.    #
# Same for every run #
######################

# Nextcloud credentials. Uncomment if not using .env file
#export NEXTCLOUD_USERNAME=
#export NEXTCLOUD_PASSWORD=

# Nextcloud output root directory. Every run will create a subdir.
export NEXTCLOUD_OUTPUT_ROOT=rmlstreamerbenchmark

# RML mapping file to use. (controller)
export MAPPING_FILE=twitter_mapping.ttl

# Input file. Contents of this file is streamed to the RMLStreamer. (stream-in)
export NEXTCLOUD_INPUT_FILE=https://cloud.ilabt.imec.be/index.php/s/CkZAikeq2TpzsjY/download?path=data/1000_tweets.gz

# The total duration of the run, in seconds
export DURATION=10

######################################
# 'Variable' config                  #
# These need to change for every run #
######################################

# The total number of task slots (~cores) to use. (controller)
# PARALLELISM <= TASK_MANAGER_NUMBER_OF_TASK_SLOTS * NUMBER_OF_TASK_MANAGERS 
export PARALLELISM=4

# The number of task slots (~cores) to use for every Flink node (controller)
# PARALLELISM <= TASK_MANAGER_NUMBER_OF_TASK_SLOTS * NUMBER_OF_TASK_MANAGERS
export TASK_MANAGER_NUMBER_OF_TASK_SLOTS=6

# The number of Flink nodes (taskmanager)
# PARALLELISM <= TASK_MANAGER_NUMBER_OF_TASK_SLOTS * NUMBER_OF_TASK_MANAGERS
export NUMBER_OF_TASK_MANAGERS=1

# The time between sending messages, in *nanoseconds* (1.000.000.000ns = 1s) (stream-in).
export DELAY=500

###########################################
# 'Derived' config                        #
# Calculated from fixed / variable config #
###########################################

# The name of the run. It will be used as name of the Flink job and as
# name of the output directory. (controller)
export JOBNAME=rmlstreamer_p${PARALLELISM}_s${TASK_MANAGER_NUMBER_OF_TASK_SLOTS}_t${NUMBER_OF_TASK_MANAGERS}_d${DELAY}_$(date --utc +%F_%H:%M:%S)

# Output directory where results will be written. (stream-out)
export NEXTCLOUD_DIRECTORY=${NEXTCLOUD_OUTPUT_ROOT}/${JOBNAME}

# The actual command that brings up the containers an runs the benchmark
docker-compose -f docker-compose.yml -f docker-compose.rmlstreamer.yml up --scale taskmanager=$NUMBER_OF_TASK_MANAGERS --scale stream-in=1
#docker-compose -f docker-compose.yml -f docker-compose.rmlstreamer.yml up --scale taskmanager=$NUMBER_OF_TASK_MANAGERS --scale stream-in=8
#docker-compose -f docker-compose.yml up --scale stream-in=8
