#!/bin/bash
set -e


cd $(dirname "$0")
source ../path-functions.sh
source ../file-or-gz.sh
source ../exe-paths.sh
source convert-raw.sh
source ../hd-bet.sh


# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --study-dir)
        dir_top=$(add_slash_if_needed "$2")
        shift # past argument
        shift # past value
        ;;
        --subj)
        subj="$2"
        shift # past argument
        shift # past value
        ;;
        *)  # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done



dir_dicoms=$dir_top'dicoms/'$subj'/t1/'
dir_processed=$dir_top'structurals/'$subj/

loc_t1_raw=$dir_processed"t1-raw.nii.gz"
loc_t1_n4=$dir_processed"t1.nii.gz"
loc_t1_brainmask=$dir_processed"t1-brainmask.nii.gz"
loc_t1_brain=$dir_processed"t1-brain.nii.gz"

mkdir -p $dir_processed

ConvertStructuralFromDicom $dir_dicoms $loc_t1_raw

Skullstrip_HDBET $loc_t1_raw $loc_t1_brainmask

if [ ! -e $loc_t1_n4 ]; then
    N4BiasFieldCorrection -i $loc_t1_raw -x $loc_t1_brainmask -o $loc_t1_n4
fi

