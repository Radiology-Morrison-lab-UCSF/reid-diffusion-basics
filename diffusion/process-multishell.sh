#!/bin/bash
set -e

original_cwd=$(pwd)
source_dir=$(dirname "$0")
cd $source_dir
source ../path-functions.sh
source ../file-or-gz.sh
source convert-raw.sh
source denoise-gibbs.sh
source eddy-correct.sh
source skullstrip.sh
source fods.sh
source tensor-metrics.sh
source bias-correct-dwi.sh
source dwi-paths.sh
source process-basics.sh



# Parse command line arguments
cd $original_cwd
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
        *)  # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

cd $source_dir

# Check if required arguments are provided
if [ -z "$dir_top" ] || [ -z "$subj" ]; then
    echo "Processes single-shell HARDI data into FODs, FA, MD"
    echo "See install.sh for installation"
    echo 
    echo "Usage: process-single-shell.sh --study-dir <study-directory> --subj <subject-id>"
    echo "where <study-directory> is the absolute path to the a directory laid out like so:"
    echo "<study-directory>/dicoms/<subject-id>/diffusion_ap/*.dcm"
    echo "<study-directory>/dicoms/<subject-id>/diffusion_pa/*.dcm"
    echo "Results will be output to <study-directory>/diffusion/<subject-id>/"
    echo ""
    echo "For example for data:"
    echo "/home/lee/my-study/dicoms/mike-jones/diffusion_ap/*.dcm"
    echo "/home/lee/my-study/dicoms/mike-jones/diffusion_pa/*.dcm"
    echo "process-single-shell.sh --study-dir /home/lee/my-study/ --subj mike-jones"
    echo "would produce"
    echo "/home/lee/my-study/diffusion/mike-jones/fa.nii.gz"
    echo "/home/lee/my-study/diffusion/mike-jones/md.nii.gz"
    echo "/home/lee/my-study/diffusion/mike-jones/fod-wm.mif.gz"
    echo "etc"
    exit 1
fi

# Set parameters for output file paths
SetDWIPaths "$dir_top" $subj

PreprocessBasicDWI "$dir_top" $subj

CalcTensors $loc_preprocessed $loc_dwimask $loc_fa $loc_md

CalcKurtosis $loc_preprocessed $loc_dwimask $loc_kurtosis


MSMTFOD $loc_preprocessed $loc_dwimask $dir_diffusion



# Save some disk space
if [ -e $loc_preprocessed ]; then
    gzip $loc_preprocessed
fi

echo "QC FA and FODs"
mrview $loc_fa $loc_kurtosis -interpolation false -odf.load_sh $(GzFilepathIfOnlyGzFound "$loc_wm_fod")