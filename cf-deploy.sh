#!/bin/bash

printf "\n\n"
echo "******************************"
echo "* Deployment process started *"
echo "******************************"
printf "\n"

# login and initialize session
source cf-init.sh
if [ $? -eq 1 ]; then
   echo "Abort deployment!"
   exit -1
fi

printf "\n\n"
echo "++++++++++++++++++++++++++++++"
echo "| Run pre-processing scripts |"
echo "++++++++++++++++++++++++++++++"
printf "\n"

# run pre-processing scripts
PRE_PROCESSING_SCRIPTS=$(ls /tmp/scripts/pre-*.sh 2>/dev/null | sort)
for PRE_PROCESSING_SCRIPT in $PRE_PROCESSING_SCRIPTS; do
    
    printf "\n\nrun script: '%s'" "${PRE_PROCESSING_SCRIPT}"
    printf "\n---------------------------------------------"

    source "${PRE_PROCESSING_SCRIPT}"
done

if [ "${#PRE_PROCESSING_SCRIPTS[@]}" == 0 ]; then
    echo "no scripts to run."
fi

# carry out deployments
printf "\n\n"
echo "+++++++++++++++++++++++++++++++++"
echo "| Deploy application components |"
echo "+++++++++++++++++++++++++++++++++"
printf "\n"

IFS=',' read -r -a TASKS <<< "${APP_TASKS}"
MANIFESTS=$(ls /tmp/manifests/*.yml 2>/dev/null | sort)
for MANIFEST in $MANIFESTS; do

    # determine if a task shall be run for this app
    HAS_TASK=false
    APP_NAME="unknown"
    APP_COMMAND="unknown"
    for TASK in "${TASKS[@]}"; do
        IFS=':' read -r -a TASK_DESC <<< "${TASK}"
        # if manifest file contains name of the task, then we have a hit
        if [[ "${MANIFEST}" == *"${TASK_DESC[0]}"* ]]; then
            HAS_TASK=true
            APP_NAME="${TASK_DESC[0]}"
            APP_COMMAND="${TASK_DESC[1]}"

            break
        fi
    done

    # deploy from manifest with or without vars file
    printf "\nProcessing %s\n" "${MANIFEST}"
    if [ $HAS_TASK == true ]; then
        cf push --manifest "${MANIFEST}" --vars-file "/tmp/stage-vars/${CF_SPACE}.yml" --no-start
    else
        cf push --manifest "${MANIFEST}" --vars-file "/tmp/stage-vars/${CF_SPACE}.yml" --strategy rolling
    fi

    # run task if there is one
    if [ $HAS_TASK == true ]; then
        printf "\n\t-> command '%s' from app '%s' needs to be run\n\n" "${APP_COMMAND}" "${APP_NAME}"
        source cf-run-task.sh
    fi

    printf "\nEnd of %s processing\n\n" "${MANIFEST}"
done

if [ "${#MANIFESTS[@]}" == 0 ]; then
    echo "no application components to deploy."
fi

printf "\Application components deployed\n"

printf "\n\n"
echo "+++++++++++++++++++++++++++++++"
echo "| Run post-processing scripts |"
echo "+++++++++++++++++++++++++++++++"
printf "\n"

# run post-processing scripts
POST_PROCESSING_SCRIPT=$(ls /tmp/scripts/post-*.sh 2>/dev/null | sort)
for POST_PROCESSING_SCRIPT in $POST_PROCESSING_SCRIPT; do

    printf "\n\nrun script: '%s'" "${POST_PROCESSING_SCRIPT}"
    printf "\n----------------------------------------------"

    source "${POST_PROCESSING_SCRIPT}"
done

if [ "${#POST_PROCESSING_SCRIPT[@]}" == 0 ]; then
    echo "no scripts to run."
fi

printf "\n\n"
echo "***************************"
echo "* Deploy process finished *"
echo "***************************"
printf "\n"
