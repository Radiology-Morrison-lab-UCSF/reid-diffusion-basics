source ../file-or-gz.sh


function EddyCorrect {
    loc_in=$(GzFilepathIfOnlyGzFound "$1")
    loc_out=$2
    if file_or_gz_exists $loc_out; then
        return
    fi

    local dir_tmp=`mktemp -d`/
    trap "rm -rf $dir_tmp" EXIT

    local loc_b0s=$dir_tmp"b0s.mif"
    local loc_dwis=$dir_tmp"dwis.mif"
    dwiextract -force $loc_in -bzero $loc_b0s
    dwiextract -force $loc_in -no_bzero $loc_dwis

    # Extra eddy args:
    # --repol patches up the odd black slice
    # --data_is_shelled stops eddy from crashing when passed a kurtosis acquisition with many shells
    # --estimate_move_by_susceptibility improves very slightly the very frontal areas when someone has moved
    # To-do: slice to order movement
    # Requires slice timing/order which neither GE nor Philips seem to include in dicoms headers
    # --mporder=6 --slspec=my_slspec.txt --s2v_niter=5 --s2v_lambda=1 --s2v_interp=trilinear"
    local eddyArgs=" --repol --data_is_shelled --estimate_move_by_susceptibility "

    dwifslpreproc $loc_in $loc_out -rpe_header -se_epi $loc_b0s -align_seepi -eddy_options "$eddyArgs" -scratch "$dir_tmp"

}