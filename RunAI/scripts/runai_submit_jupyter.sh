#!/bin/bash
# Usage
# source runai_submit_jupyter.sh job_name num_gpu
# Examples:
#	`source runai_submit_jupyter.sh ep-jupyter-pod 1
#	- creates a job named `ep-jupyter-pod`
#	- uses 1 GPU
#	- runs jupyter lab on port 8888

arg_job_name=$1
arg_gpu=$2

CLUSTER_USER="?" # Your epfl username.
CLUSTER_USER_ID="?"  # Your epfl UID.
CLUSTER_GROUP_NAME="ivrl" # Your group name.
CLUSTER_GROUP_ID="11227"  # Your epfl GID
#MY_IMAGE="ic-registry.epfl.ch/ivrl/ubuntu20-base" # Change accordingly
#MY_IMAGE="ic-registry.epfl.ch/ivrl/pytorch1.10:cuda11.3"
MY_IMAGE="ic-registry.epfl.ch/ivrl/datascience-python"

arg_cmd="source /opt/lab/setup.sh && su $CLUSTER_USER -c 'jupyter lab --ip=0.0.0.0 --no-browser --notebook-dir=/scratch'"

echo "Job [$arg_job_name] gpu $arg_gpu -> [$arg_cmd]"

# To submit an interactive job add --interactive bellow
# Change pvc accordingly
# Fill the ??? with your epfl username

runai submit $arg_job_name \
  -i $MY_IMAGE \
  --gpu $arg_gpu \
  --interactive \
  --port 8888:8888 \
  --pvc runai-ivrl-???-ivrldata2:/data \
  --pvc runai-ivrl-???-scratch:/scratch \
  --large-shm \
  -e CLUSTER_USER=$CLUSTER_USER \
  -e CLUSTER_USER_ID=$CLUSTER_USER_ID \
  -e CLUSTER_GROUP_NAME=$CLUSTER_GROUP_NAME \
  -e CLUSTER_GROUP_ID=$CLUSTER_GROUP_ID \
  --host-ipc \
  --command -- /bin/bash -c $arg_cmd
sleep 1

runai describe job $arg_job_name
