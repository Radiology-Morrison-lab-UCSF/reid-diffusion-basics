#!/bin/bash
set -e


dir_top=/Users/lee/data/2024-02-29-test-qb3/
dir_dicoms_top=$dir_top"dicoms/"
dir_dicoms_ap=$dir_dicoms_top"diffusion_1_ap/"
dir_dicoms_pa=$dir_dicoms_top"diffusion_1_pa/"
dir_diffusion=$dir_top"diffusion_1/"

loc_dwi_raw=$dir_diffusion"raw.mif"
loc_denoised=$dir_diffusion"denoised.mif"
loc_preprocessed=$dir_diffusion"preprocessed.mif"
loc_fa=$dir_diffusion"fa.nii.gz"
loc_md=$dir_diffusion"md.nii.gz"
loc_mask=$dir_diffusion"mask.mif"

source convert-raw.sh
source denoise-gibbs.sh
source eddy-correct.sh
source skullstrip.sh
source ssmtfod.sh
source tensor-metrics.sh


mkdir -p $dir_diffusion

ConvertRaw $dir_dicoms_ap $dir_dicoms_pa $loc_dwi_raw

DenoiseAndGibbs $loc_dwi_raw $loc_denoised

EddyCorrect $loc_denoised $loc_preprocessed

SkullStripDWI $loc_preprocessed $loc_mask

SSMTFOD $loc_preprocessed $dir_diffusion

CalcTensors $loc_preprocessed $loc_mask $loc_fa $loc_md

mrview $loc_fa -interpolation false -odf.load_sh $dir_diffusion/fod-wm.mif