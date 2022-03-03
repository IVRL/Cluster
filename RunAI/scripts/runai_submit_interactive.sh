#!/bin/bash
# Usage
# source runai_submit_interactive.sh job_name num_gpu
# Examples:
#	`source runai_submit_interactive.sh ep-jupyter-pod 1
#	- creates a job named `ep-jupyter-pod`
#	- uses 1 GPU
#	- runs jupyter lab and
#
#	`source runai_submit_train.sh ep-gpu-pod 0.5 "python hello.py"`
#	- creates a job named `ep-gpu-pod`
#	- receives half of a GPUs memory, 2 such jobs can fit on one GPU!
#	- runs `python hello.py`

arg_job_name=$1
arg_gpu=$2
arg_cmd="source /opt/lab/setup.sh && jupyter lab --ip=0.0.0.0 --no-browser --allow-root --notebook-dir=/scratch"

CLUSTER_USER="pajouheshgar" # Your epfl username.
#CLUSTER_USER="cliu" # Your epfl username.
CLUSTER_USER_ID="223000"  # Your epfl UID.
#CLUSTER_USER_ID="155860" # Your epfl UID.
CLUSTER_GROUP_NAME="ivrl" # Your group name.
CLUSTER_GROUP_ID="11227"  # Your epfl GID
#MY_IMAGE="ic-registry.epfl.ch/ivrl/ubuntu20-base" # Change accordingly
#MY_IMAGE="ic-registry.epfl.ch/ivrl/nvidia-pytorch-20-12"
MY_IMAGE="ic-registry.epfl.ch/ivrl/datascience-python"

echo "Job [$arg_job_name] gpu $arg_gpu -> [$arg_cmd]"

# To submit an interactive job add --interactive bellow
# Change pvc accordingly
runai submit $arg_job_name \
  -i $MY_IMAGE \
  --gpu $arg_gpu \
  --interactive \
  --port 8888:8888 \
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
