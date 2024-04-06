source ../file-or-gz.sh
source ../hd-bet.sh


function SkullStripDWI {
    local loc_preprocessed_dwi=$(gz-filepath-if-only-gz-found "$1")
    local loc_out=$2


    if file_or_gz_exists $loc_out; then
        echo $loc_out found. SkullStripDWI skipped
        return 0
    fi

    local dir_tmp=`mktemp -d`
    trap "rm -rf $dir_tmp" EXIT

    # Skull strip using HD BET 
    # This often will be slightly too small       
    loc_meanb0=$dir_tmp"/mean_b0.nii"
    dwiextract $loc_preprocessed_dwi - -bzero | mrmath - mean $loc_meanb0 -axis 3

    loc_mask_hdbet=$dir_tmp"/hdbet.nii"
    Skullstrip_HDBET_Quick $loc_meanb0 $loc_mask_hdbet

    # Skullstrip using dwi2mask
    # this can leave out the inferior frontal lobe
    loc_mask_dwi2mask=$dir_tmp"/dwi2mask.nii"
    dwi2mask $loc_in $loc_mask_dwi2mask

    # Combine masks
    mrcalc $loc_mask_dwi2mask $loc_mask_hdbet "-or" $loc_out

}