#!/bin/bash

source ./helpers.sh

MAPPING_FILE="twitter_mapping.ttl"
INPUT_FILE="https://cloud.ilabt.imec.be/index.php/s/CkZAikeq2TpzsjY/download?path=data/1000_tweets.gz"
TIMEOUT=20
DURATION="600"

# Process command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--engine)
    ENGINE="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--directoy)
    DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--username)
    USERNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--taskmanagerinstances)
    TASKMANGER_INSTANCES="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--taskslots)
    RMLSTREAMER_TASKSLOTS="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--parallelism)
    RMLSTREAMER_PARALLELISM="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--verbose)
    VERBOSE=true
    shift # past argument
    ;;
    -h|--help)
    echo "Usage information: "
    echo 
    echo "  -d|--directoy <path> The output directory on Nextcloud. (Required)"
    echo "  -e|--engine <string> The engine that executes the query. (triplewave) (Required)"
    echo "  -u|--username <string> The Nextcloud user name to use. (Optional, default: $USER)"
    echo "  -s|--taskslots <int> The number of task slots. (Only for RMLStreamer) (Optional, default: 4)"
    echo "  -p|--parallelism <int> Set the parallism of Flink. (Only for RMLStreamer) (Optional, default: 4)"
    echo "  -c|--taskmanagerinstances <int> The number of taskmanager instances. (Only for RMLStreamer) (Optional, default: 1)"
    echo "  -v|--verbose Output more information."
    echo "  -h|--help   The usage of information."
    exit 0;
    ;;
esac
done

ENGINE="${ENGINE,,}" # To lowercase

VALID_ENGINES=("triplewave" "rmlstreamer")
if [[ ! " ${VALID_ENGINES[@]} " =~ " ${ENGINE} " ]]; then
  >&2 echo "Please provide a valid engine (${VALID_ENGINES[@]}) via -e|--engine."
  exit 1;
fi

log "Engine: $ENGINE"

if [ "$USERNAME" == "" ]; then
  USERNAME=$USER
fi

log "User name: $USERNAME"

if [ "$DIRECTORY" == "" ]; then
  >&2 echo "Please provide a directory via -d|--directory."
  exit 1;
fi

log "Directory: $DIRECTORY"

if [ "$INPUT_FILE" == "" ]; then
  >&2 echo "Please provide an input file via -i|--inputfile."
  exit 1;
fi

if [[ "$RMLSTREAMER_TASKSLOTS" == "" ]]; then
  RMLSTREAMER_TASKSLOTS=4
fi

log "RMLStreamer tasks slots: $RMLSTREAMER_TASKSLOTS"

if [[ "$RMLSTREAMER_PARALLELISM" == "" ]]; then
  RMLSTREAMER_PARALLELISM=4
fi

log "RMLStreamer parallelism: $RMLSTREAMER_PARALLELISM"

if [[ "$TASKMANGER_INSTANCES" == "" ]]; then
  TASKMANGER_INSTANCES="1"
fi

log "Taskmanager instances: $TASKMANGER_INSTANCES"
log ""

delays=(0 100000 1000000 10000000 100000000 1000000000)

for delay in "${delays[@]}"
do
  jobname="p${RMLSTREAMER_PARALLELISM}_s${RMLSTREAMER_TASKSLOTS}_t${TASKMANGER_INSTANCES}_d${delay}"
  log "Current job: $jobname"
  ./run-single-test.sh -e $ENGINE -d ${DIRECTORY}/${jobname} -t $TIMEOUT -u $USERNAME -i $INPUT_FILE -s $RMLSTREAMER_TASKSLOTS -p $RMLSTREAMER_PARALLELISM -j $jobname -m $MAPPING_FILE -a $delay -r $DURATION -v -c $TASKMANGER_INSTANCES
  log "Job done: $jobname"
done
