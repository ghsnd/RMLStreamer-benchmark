## Prints message when verbose is enabled.
log () {
  local MESSAGE=$1
  
  if [[ "$VERBOSE" == "true" ]]; then
    >&2 echo $MESSAGE
  fi
}

getDuration () {
  NOW=$1
  POD_NAME=$2
  
  TIME=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{.metadata.creationTimestamp}}{{"\n"}}{{end}}' | grep $POD_NAME`
  #>&2 echo $TIME
  START="${TIME/$POD_NAME/''}"
  #>&2 echo "CURRENT = $START"
  START=$(date +%s -d $START)

  MINUTES=$(( ($NOW - $START) / 60 ))

  echo $MINUTES
}

getEnginePodName () {
  local ENGINE=$1
  line=`kubectl get pods | grep -v Terminating| grep $ENGINE`
  NAME=($line)
  
  echo $NAME
}