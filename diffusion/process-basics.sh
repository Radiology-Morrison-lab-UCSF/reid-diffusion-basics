#!/bin/bash
set -e

original_cwd=$(pwd)
source_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))
cd $source_dir
source ../path-functions.sh
source ../file-or-gz.sh
source ../exe-paths.sh
source convert-raw.sh
source denoise-gibbs.sh
source eddy-correct.sh
source skullstrip.sh
source tensor-metrics.sh
source bias-correct-dwi.sh
source dwi-paths.sh


cd $source_dir

PreprocessBasicDWI(){
    local dir_top="$1"
    local subj="$2"

    # Set parameters for output file paths in case not already called
    SetDWIPaths "$dir_top" $subj

    # Check first in case working files have been cleaned up
    if file_or_gz_exists $loc_preprocessed $loc_dwimask; then
        echo Found preprocessed diffusion, mask, and fods
    else
        mkdir -p $dir_diffusion

        ConvertRaw $dir_dicoms_ap $dir_dicoms_pa $loc_dwi_raw

        DenoiseAndGibbs $loc_dwi_raw $loc_denoised

        InsertUndistortedB0IfExists $loc_denoised $dir_dicoms_online_distortion_corrected $loc_denoise_with_any_corrected_b0

        EddyCorrect $loc_denoised $loc_eddyCorrected

        SkullStripDWI $loc_eddyCorrected $loc_dwimask

        BiasCorrect $loc_eddyCorrected $loc_dwimask $loc_preprocessed

    fi

    # Save some disk space
    rm -f $loc_dwi_raw $loc_denoised $loc_eddyCorrected $loc_denoise_with_any_corrected_b0
}
