#!/usr/bin/env bash

# URL of the Job Manager
echo "Job Manager URL = $JOB_MANAGER_URL"
echo "RMLStreamer jar URL = $RMLSTREAMER_URL"

if [[ "$SOCKET" == "file" ]]
then
  echo "Waiting until stream-in containers become ready..."
  for i in {0..7}
  do
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' stream-in-$i:3000)" != "200" ]]; do sleep 1; done
    echo "stream-in-$i ready."
  done
else
  echo "Waiting until stream-out and stream-in containers become ready..."
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' stream-in:3000)" != "200" ]]; do sleep 1; done
  echo "stream-in is ready!"
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' stream-out:3000)" != "200" ]]; do sleep 1; done
  echo "stream-out is ready!"
fi

# wait for the jobmanager to become online
JOBMANAGEROVERVIEW=$(curl -s $JOB_MANAGER_URL/overview)
while [[ $JOBMANAGEROVERVIEW == "" ]]; do
  echo "No Job Manager found. Trying again in 2 seconds."
  sleep 2
  JOBMANAGEROVERVIEW=$(curl -Is $JOB_MANAGER_URL/overview)
done
echo "Jobmanager found"


# wait for at least one task manager to become online
getNumberOfTaskManagers() {
  number=$(curl -s $JOB_MANAGER_URL/overview | jq -r '.taskmanagers')

  if [[ $number == "" ]]; then
    number=0
  fi
  echo "$number taskmanagers found"
}
# TODO: wait until configured nr of taskmanagers is online.
NUMBER_OF_TASKMANAGERS=$(getNumberOfTaskManagers)
while [[ "$NUMBER_OF_TASKMANAGERS" < "1" ]]; do
  echo "$NUMBER_OF_TASKMANAGERS task managers available, expecting at least 1. Trying again in 2 seconds."
  sleep 2
  NUMBER_OF_TASKMANAGERS=$(getNumberOfTaskManagers)
done
echo "At least one task manager is already available. Let's continue."

# get RMLStreamer jar
echo 'Getting RMLStreamer jar and mapping file'
wget $RMLSTREAMER_URL -O RMLStreamer.jar

# Upload RMLStreamer
echo "Uploading RMLStreamer jar..."
streamerJarId=$(curl -s -X POST -H "Expect:" -F "jarfile=@RMLStreamer.jar" $JOB_MANAGER_URL/v1/jars/upload | jq -r '.filename')
echo "JarId of the RMLStreamer = $streamerJarId"
echo "RMLStreamer jar uploaded."

# run the job
echo "Starting the job..."
if [[ "$SOCKET" == "file" ]]
then
  jobid=$(curl -s -X POST \
    $JOB_MANAGER_URL/v1/jars/$(basename -- "$streamerJarId")/run \
    -H 'Content-Type: application/json' \
    -d "{
       \"parallelism\": $PARALLELISM,
       \"programArgs\": \"noOutput --mapping-file /etc/mappings/$MAPPING_FILE --job-name $JOBNAME\"
     }" | jq -r '.jobid')
else
  jobid=$(curl -s -X POST \
    $JOB_MANAGER_URL/v1/jars/$(basename -- "$streamerJarId")/run \
    -H 'Content-Type: application/json' \
    -d "{
       \"parallelism\": $PARALLELISM,
       \"programArgs\": \"toTCPSocket --mapping-file /etc/mappings/$MAPPING_FILE --job-name $JOBNAME --output-socket $SOCKET\"
     }" | jq -r '.jobid')
fi
echo "Job ID: $jobid"
