#!/bin/bash

source ./helpers.sh

MAPPING_FILE="twitter_mapping.ttl"
INPUT_FILE="https://cloud.ilabt.imec.be/index.php/s/CkZAikeq2TpzsjY/download?path=data/100000_tweets.txt"
TIMEOUT=10
DURATION="600s"

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
    -a|--delay)
    DELAY="$2"
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
    echo "  -a|--delay <string> The delay of messages from stream-in. (Required)"
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

if [[ "$DELAY" == "" ]]; then
  >&2 echo "Please provide a delay via -a|--delay."
  exit 1;
fi

log "Delay: $DELAY"
log ""

firstrow="true"
IFS=','
while read parallelism taskslots numberoftaskmanagers
do
  if [[ "$firstrow" == "false" ]]; then
    jobname="p${parallelism}_s${taskslots}_t${numberoftaskmanagers}_d${DELAY}_${date --utc +%F_%H:%M:%S}"
    log "Current job: $jobname"
    #./run-single-test.sh -e $ENGINE -d ${DIRECTORY}/${jobname} -t $TIMEOUT -u $USERNAME -i $INPUT_FILE -s $taskslots -p $parallelism -j $jobname -m $MAPPING_FILE -a $DELAY -r $DURATION -v
    log "Job done: $jobname"
  fi

  firstrow="false"
done < test.csv
