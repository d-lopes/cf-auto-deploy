#!/bin/bash

if [ "${APP_NAME}x" = "x" ] || [ "${APP_COMMAND}x" = "x" ]; then
    echo "APP_NAME and APP_COMMAND must be defined."
    exit 1
fi

printf "\nStart %s\n" "${APP_NAME}"
cf start "${APP_NAME}"

TASK_NAME="${APP_NAME}_task_${RANDOM}.${RANDOM}"
printf "\nRun and wait for task %s\n" "${TASK_NAME}"
cf run-task "${APP_NAME}" --name "${TASK_NAME}" --command "${APP_COMMAND}"

set +x
printf "Busy waiting for %s to finish.\n" "${TASK_NAME}"
TASK_RESULT=$(cf tasks "${APP_NAME}" | grep  "${TASK_NAME}" | awk '{ print $3 }')
while [[ $TASK_RESULT != "SUCCEEDED" ]]; do
  if [[ $TASK_RESULT == "FAILED" ]]; then
    printf "Task reported failure. Check logs with:\ncf logs --recent %s\n" "${APP_NAME}"
    exit 1
  fi
  sleep 1
 TASK_RESULT=$(cf tasks "${APP_NAME}" | grep "${TASK_NAME}" | awk '{ print $3 }')
done
printf "%s successfully finished.\n" "${TASK_NAME}"

printf "\nStop %s\n" "${APP_NAME}"
cf stop "${APP_NAME}"
