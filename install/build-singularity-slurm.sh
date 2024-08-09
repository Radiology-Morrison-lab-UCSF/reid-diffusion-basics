#!/bin/bash
# 
set -e


# Function to display help message
print_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -h, --help    Display this help message and exit."
    echo
    echo "Description:"
    echo "  Sends a build request for the singularity image to slurm."
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
    exit 0
fi

current_script="$(realpath "${BASH_SOURCE[0]}")"

cd $(realpath $(dirname "$current_script")/)

pathToScripts=$(pwd)/build-singularity.sh
workingDir=$(dirname "$current_script")

set -x

sbatch  --nodes=1 \
        --mem=64GB \
        --cpus-per-task=8 \
        --chdir="$workingDir" \
        --time="2:00:00" \
        --job-name="build-reid-diffusion-basics" \
        "$pathToScripts"
