original_cwd=$(pwd)
source_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))
cd $source_dir
source ../file-or-gz.sh
cd $original_cwd

function InsertUndistortedB0IfExists {
    # Inserts any undistorted b0s in the mix for subsequent use of eddy
    loc_dwi=$(GzFilepathIfOnlyGzFound "$1")
    dir_undistortedDicoms=$(GzFilepathIfOnlyGzFound "$2")
    loc_out="$3"

    if [ ! -f "$dir_undistortedDicoms" ]; then
        echo  No undistorted B0s found in $dir_undistortedDicoms. Eddy will run normally.
        return
    fi

    echo "Found an undistorted B0 in $dir_undistortedDicoms. Adding into the image sequence to guide eddy."

    # We state the image was acquired with effectively infinite bandwidth
    mrconvert "$dir_undistortedDicoms" - | \
	    dwiextract - -bzero - | \
	    mrconvert -clear-property PixelBandwidth -set-property TotalReadoutTime 0 -set-property PhaseEncodingDirection j | \
	    mrcat -force "$loc_dwi" - "$loc_denoise_with_any_corrected_b0"
}

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
    local noCPUS=$(nproc --all)
    local eddyArgs=" --repol --data_is_shelled --estimate_move_by_susceptibility --nthr=$noCPUS"

    origDir=$(pwd)
    cd "$dir_tmp" # switch as this script forcefully tries to write to the cwd

    export PATH="$PATH":"$FSLDIR/bin" # for whatever reason the fsl activate doesn't work
    $loc_python $dir_mrtrix_3tissue/dwifslpreproc $loc_in $loc_out -rpe_header -se_epi $loc_b0s -align_seepi -eddy_options "$eddyArgs" -scratch "$dir_tmp" 
    cd "$origDir"
}