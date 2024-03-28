#!/bin/bash
set -e

source convert-raw.sh
source denoise-gibbs.sh
source eddy-correct.sh
source skullstrip.sh
source ssmtfod.sh
source tensor-metrics.sh
source file-or-gz.sh


# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --study-dir)
        dir_top="$2"
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


# Set directories
dir_top=$(add_slash_if_needed "$dir_top")
dir_dicoms_top=$dir_top"dicoms/"$subj"/"
dir_dicoms_ap=$dir_dicoms_top"diffusion_ap/"
dir_dicoms_pa=$dir_dicoms_top"diffusion_pa/"
dir_diffusion=$dir_top"diffusion/"$subj"/"

loc_dwi_raw=$dir_diffusion"raw.mif"
loc_denoised=$dir_diffusion"denoised.mif"
loc_preprocessed=$dir_diffusion"preprocessed.mif"
loc_wm_fod=$dir_diffusion"fod-wm.mif"
loc_fa=$dir_diffusion"fa.nii.gz"
loc_md=$dir_diffusion"md.nii.gz"
loc_mask=$dir_diffusion"mask.mif"


# Check first in case working files have been cleaned up
if file_or_gz_exists $loc_preprocessed $loc_wm_fod; then
    echo Found preprocessed diffusion and fods
else
    mkdir -p $dir_diffusion

    ConvertRaw $dir_dicoms_ap $dir_dicoms_pa $loc_dwi_raw

    DenoiseAndGibbs $loc_dwi_raw $loc_denoised

    EddyCorrect $loc_denoised $loc_preprocessed

    SkullStripDWI $loc_preprocessed $loc_mask

    SSMTFOD $loc_preprocessed $dir_diffusion
fi

CalcTensors $loc_preprocessed $loc_mask $loc_fa $loc_md

mrview $loc_fa -interpolation false -odf.load_sh $loc_wm_fod