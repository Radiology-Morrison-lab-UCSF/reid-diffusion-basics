
function CleanupTmpDir {
    rm -rf $dir_tmp
}



ensure_tag() {
    # Sets the tag to that provided if not found

    # Check if the filename is provided
    if [ $# -ne 3 ]; then
        echo "Usage: ensure_tag <image> <tag_key> <default_tag_value>"
        return 1
    fi

    img=$1
    key=$2
    def_val=$3

    # Call mrinfo and extract the output
    local mrinfo_output=$(mrinfo "$img")

    # Check if mrinfo failed
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute mrinfo on '$img'."
        return 1
    fi

    if ! echo "$mrinfo_output" | grep -q "\b$key:"; then
        
        echo "Warning: $key was not found for $img. Forcibly set to $def_val." >&2
        tmpfile=`mktemp`
        rm $tmpfile
        mrconvert $img $tmpfile.mif -force -set_property $key $def_val
        mv $tmpfile.mif $img
    fi
}

function ConvertRaw() {
    # $1 is the AP dicom dir
    # $2 is the PA dicom dir
    # $3 is where to save
    
    loc_out=$3
    if [ -e $loc_out ]; then
        return
    fi

    dir_tmp=`mktemp -d`
    trap CleanupTmpDir EXIT
    
    loc_temp_ap=$dir_tmp"temp_ap.mif"
    loc_temp_pa=$dir_tmp"temp_pa.mif"

    # Note: 
    # mrconvert works fine on siemens and GE dicoms but can fail on Philips due to use of JPEG2000 encoding
    # of pixel data, which is unsupported
    # To make this as universal as possible, we use dcm2niix, which also gives an estimated TotalReadoutTime
    # where information is available, rather than us having to calculate it ourselves. Note that dcm2niix
    # itself doesn't guarantee proper JPEG2000 decoding - this seems to be a beta feature at the time of 
    # writing
    dcm2niix -o $dir_tmp $1
    mrconvert -force $dir_tmp/*.nii* -json_import $dir_tmp/*.json -fslgrad $dir_tmp/*bvec $dir_tmp/*bval $loc_temp_ap

    ensure_tag $loc_temp_ap "PhaseEncodingDirection" j-
    ensure_tag $loc_temp_ap "TotalReadoutTime" 0.046

    rm $dir_tmp/*
    dcm2niix -o $dir_tmp $2
    mrconvert -force $dir_tmp/*.nii* -json_import $dir_tmp/*.json -fslgrad $dir_tmp/*bvec $dir_tmp/*bval $loc_temp_pa
    
    ensure_tag $loc_temp_pa "PhaseEncodingDirection" j
    # Make sure total readout time is there. It doesn't actually matter
    # what this value is, so long as AP and PA match, and they genuinely
    # matched during scanning
    ensure_tag $loc_temp_pa "TotalReadoutTime" 0.046

    mrcat $loc_temp_ap $loc_temp_pa $loc_out

    CleanupTmpDir
}