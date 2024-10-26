#!/bin/bash

set -e

PrintHelp() {
    echo "The following scripts are available. Type their name to see more information:"
    echo "diffusion-single-shell (For single shell data)"
    echo "diffusion-multishell (For multishell data)"
    echo "prepare-t1 (Basic T1 clean and skull strip)"
    echo "t1-to-diffusion (Aligns the T1 with diffusion. Run T1 and diffusion processing first."
}

if [[ $# -eq 0 ]]; then
    PrintHelp
    exit 1
fi

current_script="$(realpath "${BASH_SOURCE[0]}")"
dir_sourceTop=$(dirname "$current_script")/


key="$1"
shift
case $key in
    diffusion-single-shell)
    "$dir_sourceTop"/diffusion/process-single-shell.sh "$@"
    ;;
    diffusion-multishell)
    "$dir_sourceTop"/diffusion/process-multishell.sh "$@"
    ;;
    prepare-t1)
    "$dir_sourceTop"/t1-processing/prepare-t1.sh "$@"
    ;;
    t1-to-diffusion)
    "$dir_sourceTop"/t1-to-diffusion.sh "$@"
    ;;
    --help)
    PrintHelp
    exit 1
    ;;
    -h)
    PrintHelp
    exit 1
    ;;
    *)  # unknown option
    echo "Unknown option: $1"
    PrintHelp
    exit 1
    ;;
esac
