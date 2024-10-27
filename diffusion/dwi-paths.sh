SetDWIPaths(){
    local dir_top=$(add_slash_if_needed "$1")
    local subj=$2
    dir_dicoms_t1=$dir_top'dicoms/'$subj'/t1/'
    dir_processed=$dir_top'structurals/'$subj/

    dir_dicoms_top=$dir_top"dicoms/"$subj"/"
    dir_dicoms_ap=$dir_dicoms_top"diffusion_ap/"
    dir_dicoms_pa=$dir_dicoms_top"diffusion_pa/"
    dir_dicoms_online_distortion_corrected=$dir_dicoms_top"diffusion_distortion_corrected/"
    dir_diffusion=$dir_top"diffusion/"$subj"/"

    loc_dwi_raw=$dir_diffusion"raw.mif"
    loc_denoised=$dir_diffusion"denoised.mif"
    loc_denoise_with_any_corrected_b0=$dir_diffusion"denoised-plus-corrected-b0s.mif"
    loc_eddyCorrected=$dir_diffusion"eddy-corrected.mif"
    loc_preprocessed=$dir_diffusion"preprocessed.mif"
    loc_wm_fod=$dir_diffusion"fod-wm.mif.gz"
    loc_fa=$dir_diffusion"fa.nii.gz"
    loc_md=$dir_diffusion"md.nii.gz"
    loc_kurtosis=$dir_diffusion"kurtosis.mif.gz"
    loc_kurtosis_mean=$dir_diffusion"kurtosis-mean.nii.gz"
    loc_kurtosis_axial=$dir_diffusion"kurtosis-axial.nii.gz"
    loc_kurtosis_radial=$dir_diffusion"kurtosis-radial.nii.gz"
    loc_dwimask=$dir_diffusion"mask.mif"
}