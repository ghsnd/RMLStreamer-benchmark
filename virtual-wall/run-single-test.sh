#!/bin/bash

source ./helpers.sh

# Process command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -t|--timout)
    TIMEOUT="$2"
    shift # past argument
    shift # past value
    ;;
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
    -j|--jobname)
    RMLSTREAMER_JOBNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--delay)
    DELAY="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--inputfile)
    INPUT_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--duration)
    DURATION="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--mappingfile)
    MAPPING_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--taskmanagerinstances)
    TASKMANGER_INSTANCES="$2"
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
    echo "  -e|--engine <string> The engine that executes the query. (triplewave rmlstreamer) (Required)"
    echo "  -t|--timeout <int> The maximum amount of minutes a test can run. (Optional, default: 10)"
    echo "  -u|--username <string> The Nextcloud user name to use. (Optional, default: $USER)"
    echo "  -i|--inputfile <string> The Nextcloud input file to use. (Required)"
    echo "  -s|--taskslots <int> The number of task slots. (Only for RMLStreamer) (Optional, default: 4)"
    echo "  -p|--parallelism <int> Set the parallism of Flink. (Only for RMLStreamer) (Optional, default: 4)"
    echo "  -j|--jobname <string> The name of the Flink job. (Only for RMLStreamer) (Required)"
    echo "  -m|--mappingfile <string> The mapping file to use. (Required)"
    echo "  -a|--delay <string> The delay of messages from stream-in. (Optional, default: 0)"
    echo "  -r|--duration <string> The duration of stream-in. (Optional, default: 600)"
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

if [ "$TIMEOUT" == "" ]; then
  TIMEOUT=10
fi

log "Timeout: $TIMEOUT"

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

log "Input file: $INPUT_FILE"

if [ "$MAPPING_FILE" == "" ]; then
  >&2 echo "Please provide a mapping file via -m|--mappingfile."
  exit 1;
fi

log "Mapping file: $MAPPING_FILE"

if [[ "$RMLSTREAMER_TASKSLOTS" == "" ]]; then
  RMLSTREAMER_TASKSLOTS=4
fi

log "RMLStreamer tasks slots: $RMLSTREAMER_TASKSLOTS"

if [[ "$RMLSTREAMER_PARALLELISM" == "" ]]; then
  RMLSTREAMER_PARALLELISM=4
fi

log "RMLStreamer parallelism: $RMLSTREAMER_PARALLELISM"

if [[ "$DELAY" == "" ]]; then
  DELAY="0"
fi

log "Delay: $DELAY"

if [[ "$DURATION" == "" ]]; then
  DURATION="600"
fi

log "Duration: $DURATION"

if [[ "$TASKMANGER_INSTANCES" == "" ]]; then
  TASKMANGER_INSTANCES="1"
fi

log "Taskmanager instances: $TASKMANGER_INSTANCES"

if [[ "$RMLSTREAMER_JOBNAME" == "" && "$ENGINE" == "rmlstreamer" ]]; then
  >&2 echo "Please provide the name of the Flink job via -j|--jobname."
  exit 1;
fi

if [[ "$RMLSTREAMER_JOBNAME" != "" ]]; then
  log "RMLStreamer job name: $RMLSTREAMER_JOBNAME"
fi

rm -rf tmp
mkdir tmp

# Set Nextcloud variables in deployment files.
cp stream-in-*.yaml tmp/

sed -i "s|{{NEXTCLOUD_USERNAME}}|$USERNAME|" tmp/stream-in-deployment.yaml
sed -i "s|{{NEXTCLOUD_DIRECTORY}}|$DIRECTORY|g" tmp/stream-in-deployment.yaml
sed -i "s|{{NEXTCLOUD_INPUT_FILE}}|$INPUT_FILE|g" tmp/stream-in-deployment.yaml
sed -i "s|{{DELAY}}|$DELAY|g" tmp/stream-in-deployment.yaml
sed -i "s|{{DURATION}}|$DURATION|g" tmp/stream-in-deployment.yaml

if [[ "$ENGINE" == "rmlstreamer" ]]; then
  cp rmlstreamer/*.yaml tmp
  
  sed -i "s|{{PARALLELISM}}|$RMLSTREAMER_PARALLELISM|g" tmp/controller-deployment.yaml
  sed -i "s|{{JOBNAME}}|$RMLSTREAMER_JOBNAME|g" tmp/controller-deployment.yaml
  sed -i "s|{{MAPPING_FILE}}|$MAPPING_FILE|g" tmp/controller-deployment.yaml
  
  sed -i "s|{{NEXTCLOUD_USERNAME}}|$USERNAME|" tmp/stream-out-deployment.yaml
  sed -i "s|{{NEXTCLOUD_DIRECTORY}}|$DIRECTORY|g" tmp/stream-out-deployment.yaml
  
  sed -i "s|{{TASK_MANAGER_NUMBER_OF_TASK_SLOTS}}|$RMLSTREAMER_TASKSLOTS|g" tmp/taskmanager-deployment.yaml
  sed -i "s|{{REPLICAS}}|$TASKMANGER_INSTANCES|g" tmp/taskmanager-deployment.yaml
fi

cd tmp 

files=`ls -1p | grep -v / | xargs echo | sed 's/ /,/g'`

log "Deleting of existing deployments, services, and jobs..."

kubectl delete deployment,svc,job --all &> /dev/null

amountOfRunningPods=`kubectl get pods  2> /dev/null | wc -l`

while [[ "$amountOfRunningPods" != "0" ]]; do
  log "Waiting till old pods are terminated..."
  sleep 5
  amountOfRunningPods=`kubectl get pods  2> /dev/null | wc -l`
done

log "Deleting of existing deployments, services, and jobs done."

log "Running $files on Kubernetes..."

if [[ "$VERBOSE" == "true" ]]; then
  kubectl create -f $files
else
  kubectl create -f $files &> /dev/null
fi

POD_NAME=$(getEnginePodName "stream-out")
log "Pod name of stream-out: $POD_NAME"

JOB_DURATION=$(getDuration `date +%s` $POD_NAME)
podLogs=`kubectl logs $POD_NAME 2>&1`

# We wait till engine is finished.
while [[ ( "$podLogs" != *"Uploading done!"* || "$podLogs" == *"ContainerCreating"* ) && "$JOB_DURATION" -lt "$TIMEOUT" ]]; do
    log "Sleeping for 5s..."
    sleep 5
    podLogs=`kubectl logs $POD_NAME 2>&1`
    JOB_DURATION=$(getDuration `date +%s` $POD_NAME)
done

if [[ "$podLogs" == *"Uploading done!"* ]]; then
  >&2 echo "$ENGINE is done."
else
  log "Logs:"
  log "$podLogs"
  log "Job duration: $JOB_DURATION ($TIMEOUT)"

  echo "$ENGINE did not finish on time."
  exit 1
fi


