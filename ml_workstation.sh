#!/bin/bash
# Run services for ML development.
cd ~/dev && nohup jupyter lab --no-browser --port 1234 &
cd ~/models && nohup tensorboard --logdir ~/models/runs &
