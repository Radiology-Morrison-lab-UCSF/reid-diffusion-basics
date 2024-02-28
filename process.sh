#!/bin/bash
set -e

dir_mrtrix_3tissue=~/binaries/MRtrix3Tissue/bin/
loc_python=$(dirname "$0")/env/bin/python

dir_top=/Users/lee/data/2024-02-28-MB3-test-moses/
dir_dicoms_top=$dir_top"dicoms/"
dir_dicoms_ap=$dir_dicoms_top"diffusion_1_ap/"
dir_dicoms_pa=$dir_dicoms_top"diffusion_1_pa/"
dir_diffusion=$dir_top"diffusion/"

loc_dwi_raw=$dir_diffusion"raw.mif"

cd $dir_top

function CleanupTmpDir {
    rm -rf $dir_tmp
}

function ConvertRaw() {
    loc_out=$3
    if [ -e $loc_out ]; then
        return
    fi

    dir_tmp=`mktemp -d`
    trap CleanupTmpDir EXIT
    
    loc_temp_ap=$dir_tmp"temp_ap.mif"
    loc_temp_pa=$dir_tmp"temp_pa.mif"

    dcm2niix -o $dir_tmp $1
    mrconvert -force $dir_tmp/*.nii* -json_import $dir_tmp/*.json -fslgrad $dir_tmp/*bvec $dir_tmp/*bval $loc_temp_ap

    rm $dir_tmp/*
    dcm2niix -o $dir_tmp $2
    mrconvert -force $dir_tmp/*.nii* -json_import $dir_tmp/*.json -fslgrad $dir_tmp/*bvec $dir_tmp/*bval $loc_temp_pa
    
    mrcat $loc_temp_ap $loc_temp_pa $loc_out
    mrinfo $loc_out 

    CleanupTmpDir
}

function DenoiseAndGibbs {
    loc_in=$1
    loc_out=$2
    if [ ! -f $loc_out ]; then 
        dwidenoise $loc_in - | mrdegibbs - $loc_out -axes 0,1
    fi
}


function EddyCorrect {
    loc_in=$1
    loc_out=$2
    if [ -f $loc_out ]; then
        return
    fi

    dir_tmp=`mktemp -d`
    trap CleanupTmpDir EXIT

    loc_b0s=$dir_tmp"/b0s.mif"
    loc_dwis=$dir_tmp"/dwis.mif"
    dwiextract -force $loc_in -bzero $loc_b0s
    dwiextract -force $loc_in -no_bzero $loc_dwis
    dwifslpreproc $loc_in $loc_out -rpe_header -se_epi $loc_b0s -align_seepi
    
    CleanupTmpDir
}

function SkullStrip {
    loc_in=$1
    loc_out=$2
    if [ ! -f $loc_in ]; then
        dwi2mask $loc_in $loc_out
    fi
}


function SSMTFOD() {
    loc_in=$1
    loc_mask=$2
    dir_out=$3

    loc_resp_wm=$dir_out/response-wm.txt
    loc_resp_gm=$dir_out/response-gm.txt
    loc_resp_csf=$dir_out/response-csf.txt
    loc_fod_wm=$dir_out/fod-wm.mif
    loc_fod_gm=$dir_out/fod-gm.mif
    loc_fod_csf=$dir_out/fod-csf.mif

    if [ -f "$loc_resp_wm" ] && \
       [ -f "$loc_resp_gm" ] && \
       [ -f "$loc_resp_csf" ] && \
       [ -f "$loc_fod_wm" ] && \
       [ -f "$loc_fod_gm" ] && \
       [ -f "$loc_fod_csf" ]; then
        return 
    fi
    
    if [ ! -f "$loc_resp_wm" ] || \
       [ ! -f "$loc_resp_gm" ] || \
       [ ! -f "$loc_resp_csf" ]; then
        dwi2response dhollander $loc_in $dir_out/response-wm.txt $dir_out/response-gm.txt $dir_out/response-csf.txt    
    fi
    

    $loc_python $dir_mrtrix_3tissue/ss3t_csd_beta1 -mask $loc_mask $loc_in $dir_out/response-wm.txt $dir_out/fod-wm.mif $dir_out/response-gm.txt $dir_out/fod-gm.mif $dir_out/response-csf.txt $dir_out/fod-csf.mif

    mrview $dir_out/fod-wm.mif    
}

function CalcTensors {
    loc_in=$1
    loc_mask=$2
    loc_fa=$3
    loc_md=$4

    if [ -f "$loc_fa" ] && \
       [ -f "$loc_md" ] ]; then
        return 
    fi

    dwi2tensor -mask $loc_mask $loc_in - | tensor2metric  -mask $loc_mask -fa $loc_fa -adc $loc_md -force -
}


mkdir -p $dir_diffusion
loc_denoised=$dir_diffusion"denoised.mif"
loc_preprocessed=$dir_diffusion"preprocessed.mif"
loc_fa=$dir_diffusion"fa.nii.gz"
loc_md=$dir_diffusion"md.nii.gz"
loc_mask=$dir_diffusion"mask.mif"

ConvertRaw $dir_dicoms_ap $dir_dicoms_pa $loc_dwi_raw

DenoiseAndGibbs $loc_dwi_raw $loc_denoised

EddyCorrect $loc_denoised $loc_preprocessed

SkullStrip $loc_preprocessed $loc_mask

SSMTFOD $loc_preprocessed $loc_mask $dir_diffusion

CalcTensors $loc_preprocessed $loc_mask $loc_fa $loc_md

mrview $loc_fa -interpolation false -odf.load_sh $dir_diffusion/fod-wm.mif