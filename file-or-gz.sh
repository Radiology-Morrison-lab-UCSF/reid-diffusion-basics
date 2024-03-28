#!/bin/bash

file_or_gz_exists() {
    for filename in "$@"; do
        # Check if the file exists
        if [ ! -f "$filename" ] && [ ! -f "$filename.gz" ]; then
            return 1  # Failure, at least one file does not exist
        fi
    done
    return 0  # Success, all files exist
}

gz-filepath-if-only-gz-found() {
    # If the .gz version is found but the original is not, it returns the gz version
    if [ -f "$1" ]; then
        echo "$1"
    elif [ -f "$1.gz" ]; then
        echo "$1.gz"
    else
        echo "$1"
    fi
}