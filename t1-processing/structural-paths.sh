SetStructuralPaths(){
    local dir_top=$(add_slash_if_needed "$1")
    local subj=$2
    dir_dicoms_t1=$dir_top'dicoms/'$subj'/t1/'
    dir_processed_structurals=$dir_top'structurals/'$subj/

    loc_t1_raw=$dir_processed_structurals"t1-raw.nii.gz"
    loc_t1_n4=$dir_processed_structurals"t1.nii.gz"
    loc_t1_brainmask=$dir_processed_structurals"t1-brainmask.nii.gz"
    
    loc_t1_to_dwi=$dir_processed_structurals"t1-to-diffusion.mat"
    loc_t1_dwi_space=$dir_processed_structurals"t1-in-diffusion-space.nii.gz"

    loc_t1_to_mni_affine=$dir_processed_structurals"t1-to-mni-affine.mat"
    loc_t1_to_mni_nonrigid=$dir_processed_structurals"t1-to-mni-nonrigid.nii.gz"
    loc_t1_to_mni_nonrigid_inverse=$dir_processed_structurals"t1-to-mni-nonrigid-inverse-warp.nii.gz"
    loc_t1_mni_space=$dir_processed_structurals"t1-in-mni-space.nii.gz"

}