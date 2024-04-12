#!/bin/bash

set -e

source_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))
source $source_dir/file-or-gz.sh
source $source_dir/diffusion/dwi-paths.sh
source $source_dir/t1-processing/structural-paths.sh
source $source_dir/mni-roi-to-diffusion-func.sh

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --study-dir)
        dir_top=$(realpath "$2")
        shift # past argument
        shift # past value
        ;;
        --subj)
        subj="$2"
        shift # past argument
        shift # past value
        ;;
        --roi-in)
        loc_roi_in=$(realpath "$2")
        shift # past argument
        shift # past value
        ;;
        --roi-out)
        loc_roi_out="$2"
        shift # past argument
        shift # past value
        ;;
        *)  # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done


# Check if required arguments are provided
if [ -z "$dir_top" ] || [ -z "$subj" ] || [ -z "$loc_roi_in" ] || [ -z "$loc_roi_out" ]; then
    echo "Moves an ROI (or labels) from MNI to diffusion space"
    echo "Input must be 3D but can have different integer labels if needed"
    echo "Process diffusion and T1 images, then run t1-to-mni first!"
    echo "See install.sh for installation"
    echo 
    echo "Usage: t1-to-mni.sh --study-dir <study-directory> --subj <subject-id> --roi-in <path-to-roi-in-mni-space> --roi-out <path-to-save-to>"
    exit 1
fi


SetStructuralPaths $dir_top $subj
SetDWIPaths $dir_top $subj

MniRoiToDwi $loc_roi_in $loc_roi_out
