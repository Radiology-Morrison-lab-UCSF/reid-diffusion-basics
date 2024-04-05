#!/bin/bash
set -e


cd $(dirname "$0")
source ../path-functions.sh
source ../file-or-gz.sh
source ../exe-paths.sh
source convert-raw.sh
source ../hd-bet.sh
source structural-paths.sh

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


# SetStructuralPaths sets up the paths we need for t1s, brainmasks, etc
SetStructuralPaths $dir_top $subj

mkdir -p $dir_processed_structurals

ConvertStructuralFromDicom $dir_dicoms_t1 $loc_t1_raw

Skullstrip_HDBET $loc_t1_raw $loc_t1_brainmask

if [ ! -e $loc_t1_n4 ]; then
    N4BiasFieldCorrection -i $loc_t1_raw -x $loc_t1_brainmask -o $loc_t1_n4
fi

