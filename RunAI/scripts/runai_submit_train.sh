#!/bin/bash
# Usage
# bash runai_submit_train.sh job_name num_gpu "command"
# Examples:
#	`bash runai_submit_train.sh ep-gpu-pod 1 "python hello.py"`
#	- creates a job named `ep-gpu-pod`
#	- uses 1 GPU
#	- runs `python hello.py`
#
#	`bash runai_submit_train.sh ep-gpu-pod 0.5 "python hello.py"`
#	- creates a job named `ep-gpu-pod`
#	- receives half of a GPUs memory, 2 such jobs can fit on one GPU!
#	- runs `python hello.py`

arg_job_name=$1
arg_gpu=$2

CLUSTER_USER="???"                                # Your epfl username. Change accordingly
CLUSTER_USER_ID="???"                             # Your epfl UID. Change accordingly
CLUSTER_GROUP_NAME="ivrl"                         # Your group name. Change accordingly
CLUSTER_GROUP_ID="11227"                          # Your epfl GID. Change accordingly
MY_IMAGE="ic-registry.epfl.ch/ivrl/ubuntu20-base" # Change accordingly
#MY_IMAGE="ic-registry.epfl.ch/ivrl/datascience-python"
#MY_IMAGE="ic-registry.epfl.ch/ivrl/pytorch1.10:cuda11.3"

arg_cmd="source /opt/lab/setup.sh && su $CLUSTER_USER -c '$3'"

echo "Job [$arg_job_name] gpu $arg_gpu -> [$arg_cmd]"

# To submit an interactive job add --interactive bellow
# Change pvc accordingly
runai submit $arg_job_name \
  -i $MY_IMAGE \
  --gpu $arg_gpu \
  --pvc runai-pv-ivrldata2:/data \
  --pvc runai-ivrl-scratch:/scratch \
  --large-shm \
  -e CLUSTER_USER=$CLUSTER_USER \
  -e CLUSTER_USER_ID=$CLUSTER_USER_ID \
  -e CLUSTER_GROUP_NAME=$CLUSTER_GROUP_NAME \
  -e CLUSTER_GROUP_ID=$CLUSTER_GROUP_ID \
  --host-ipc \
  --command -- /bin/bash -c $arg_cmd
sleep 1

runai describe job $arg_job_name
