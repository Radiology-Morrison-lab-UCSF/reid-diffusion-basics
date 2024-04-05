source ../file-or-gz.sh

function CleanupTmpDir {
    rm -rf $dir_tmp
}

function EddyCorrect {
    loc_in=$(gz-filepath-if-only-gz-found "$1")
    loc_out=$2
    if file_or_gz_exists $loc_out; then
        return
    fi

    dir_tmp=`mktemp -d`
    trap CleanupTmpDir EXIT

    loc_b0s=$dir_tmp"/b0s.mif"
    loc_dwis=$dir_tmp"/dwis.mif"
    dwiextract -force $loc_in -bzero $loc_b0s
    dwiextract -force $loc_in -no_bzero $loc_dwis
    eddyArgs=" --repol " # patch up the odd black slice
    # To-do: slice to order movement
    # Requires slice timing/order which neither GE nor Philips seem to include in dicoms headers
    # --mporder=6 --slspec=my_slspec.txt --s2v_niter=5 --s2v_lambda=1 --s2v_interp=trilinear"

    dwifslpreproc $loc_in $loc_out -rpe_header -se_epi $loc_b0s -align_seepi -eddy_options "$eddyArgs"
    
    CleanupTmpDir
}