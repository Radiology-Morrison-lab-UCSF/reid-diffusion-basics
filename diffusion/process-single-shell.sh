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
        --visual-check)
        visualCheck=1
        shift # past argument
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
    echo "Usage: process-single-shell.sh --study-dir <study-directory> --subj <subject-id> [--visual-check]"
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
    echo ""
    echo "--visual-check automatically launches mrview to visually check results when the pipeline concludes"
    echo 
    echo "If the script encounters <study-directory>/dicoms/<subject-id>/diffusion_distortion_corrected/*.dcm it will use b0s from here to tell eddy what an undistorted image should look like"

    exit 1
fi

# Set parameters for output file paths
SetDWIPaths "$dir_top" $subj

PreprocessBasicDWI "$dir_top" $subj

# Check first in case working files have been cleaned up
if file_or_gz_exists $loc_wm_fod $loc_dwimask; then
    echo Found mask and fods
else
    SSMTFOD $loc_preprocessed $loc_dwimask $dir_diffusion
fi

CalcTensors $loc_preprocessed $loc_dwimask $loc_fa $loc_md

# Save some disk space
rm -f $loc_dwi_raw $loc_denoised $loc_eddyCorrected
if [ -e $loc_preprocessed ]; then
    gzip $loc_preprocessed
fi

echo "-----------------------------------"
echo "process-single-shell has completed"
echo "QC FA and FODs before using results"
echo "-----------------------------------"
if [ "$visualCheck" = 1 ]; then
    mrview $loc_fa -interpolation false -odf.load_sh $loc_wm_fod
fi