#!/bin/bash

# Configuration and log file paths
CONFIG_FILE="./rsync_config"
LOGFILE="sync.log"
REMOTE_HOST="kai@dojo"

# Read the node type from the config file
NODE_TYPE=$(grep '^node=' $CONFIG_FILE | cut -d'=' -f2)

# Sync function with logging and error handling
perform_sync() {
    local src="$1"
    local dest="$2"
    local attempt=1
    local max_attempts=3

    while [ $attempt -le $max_attempts ]; do
        echo "$(date "+%Y-%m-%d %H:%M:%S") - Starting rsync attempt $attempt from $src to $dest" >> $LOGFILE
        if rsync -avz --delete --exclude='.git/' $src $dest >> $LOGFILE 2>&1; then
            echo "$(date "+%Y-%m-%d %H:%M:%S") - Rsync successful from $src to $dest" >> $LOGFILE
            return 0
        else
            echo "$(date "+%Y-%m-%d %H:%M:%S") - Rsync attempt $attempt failed" >> $LOGFILE
            ((attempt++))
            sleep 10  # wait for 10 seconds before retrying
        fi
    done

    echo "$(date "+%Y-%m-%d %H:%M:%S") - All rsync attempts failed for $src to $dest, please check the issues" >> $LOGFILE
    return 1
}

# Determine sync direction and execute
sync_directories() {
    local src=$1
    local dest=$2

    if [ "$NODE_TYPE" == "home" ]; then
        perform_sync $src "$REMOTE_HOST:$dest"
    else
        perform_sync "$REMOTE_HOST:$src" $dest
    fi
}

# Process each line in the configuration file
grep -v '^node=' $CONFIG_FILE | while IFS=' ' read -r line; do
    src=$(echo $line | awk -F 'src=' '{print $2}' | cut -d' ' -f1)
    dest=$(echo $line | awk -F 'dest=' '{print $2}' | cut -d' ' -f1)

    if [ -z "$src" ] || [ -z "$dest" ]; then
        echo "Error reading src or dest from config: src='$src', dest='$dest'" >> $LOGFILE
    else
        sync_directories $src $dest
    fi
done

echo "Sync completed. Log details at $LOGFILE"

