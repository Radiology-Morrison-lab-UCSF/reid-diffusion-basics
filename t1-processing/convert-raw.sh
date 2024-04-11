source ../path-functions.sh
source ../file-or-gz.sh



function ConvertStructuralFromDicom {
    local dicom_dir=$1
    local loc_out=$2

    if file_or_gz_exists $loc_out; then
        return
    fi

    if [[ $loc_out == *.mif || $loc_out == *.mif.gz ]]; then
        # mif desired. Try to use mrtrix directly
        # If this fails, this may need to be called on the result of
        # dcm2niix
        mrconvert $dicom_dir $loc_out
    else
        # Presumably a nifti is requested
        # We use dcm2niix because it can handle JPEG2000 encoded data
        local dir_tmp=`mktemp -d`/
        trap "rm -rf $dir_tmp" EXIT

        dcm2niix -o $dir_tmp -b n $dicom_dir

        gz-safe-move $dir_tmp/*.nii* $loc_out
    fi

}