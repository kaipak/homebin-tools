#!/bin/bash
# Run services for ML development.
JUPYTER_PORT=8889
JUPYTER_OUTPUT=~/dev
TENSORBOARD_PORT=6007
TENSORBOARD_OUTPUT=~/models/runs

usage() {
  echo "Usage: ml_workstation [ -j JUPYTER_PORT ] [ -t TENSORBOARD_PORT ]";
  exit 2;
}

while getopts ":j:t:" arg; do
  case ${arg} in
    j) JUPYTER_PORT=${OPTARG}
       ;;
    t) TENSORBOARD_PORT=${OPTARG}
       ;;
    *) usage
       ;;
  esac
done

cd ~/dev && nohup jupyter lab --no-browser --port ${JUPYTER_PORT} &
cd ~/models && nohup tensorboard --port ${TENSORBOARD_PORT} --logdir ~/models/runs &
