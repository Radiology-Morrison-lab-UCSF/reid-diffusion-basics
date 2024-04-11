
SetAtlasPaths(){
    dir_all_atlases=$(realpath $(dirname "$BASH_SOURCE[0]"))

    dir_mni=$dir_all_atlases/mni_icbm152_nlin_asym_09a
    loc_mni_t1=$dir_mni/mni_icbm152_t1_tal_nlin_asym_09a.nii.gz
    loc_mni_mask=$dir_mni/mni_icbm152_t1_tal_nlin_asym_09a_mask.nii.gz
}