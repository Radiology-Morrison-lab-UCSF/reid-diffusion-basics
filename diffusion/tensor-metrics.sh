source ../file-or-gz.sh

function CalcTensors {
    local loc_in=$(GzFilepathIfOnlyGzFound "$1")
    local loc_mask=$(GzFilepathIfOnlyGzFound "$2")
    local loc_fa=$(GzFilepathIfOnlyGzFound "$3")
    local loc_md=$(GzFilepathIfOnlyGzFound "$4")

    if file_or_gz_exists "$loc_fa" "$loc_md"; then
        echo "$loc_fa" "$loc_md" found. Calculation skipped
        return 
    fi

    dwi2tensor -mask $loc_mask $loc_in - | tensor2metric - -mask $loc_mask -fa $loc_fa -adc $loc_md -force
}

CalcKurtosis(){
    local loc_in=$(GzFilepathIfOnlyGzFound "$1")
    local loc_mask=$(GzFilepathIfOnlyGzFound "$2")
    local loc_kurtosis=$(GzFilepathIfOnlyGzFound "$3")
    local loc_mean_kurt=$(GzFilepathIfOnlyGzFound "$4")
    local loc_axial_kurt=$(GzFilepathIfOnlyGzFound "$5")
    local loc_radial_kurt=$(GzFilepathIfOnlyGzFound "$6")

    if file_or_gz_exists "$loc_mean_kurt" "$loc_axial_kurt" "$loc_radial_kurt"; then
        echo Kurtosis metrics found. Calculation skipped
        return 
    fi

    local dir_tmp=`mktemp -d`/
    trap "rm -rf $dir_tmp" EXIT

    #dwi2tensor -mask $loc_mask $loc_in -dkt $loc_kurtosis - > /dev/null
    $dir_mrtrix_dev/dwi2tensor -mask $loc_mask $loc_in  -constrain -dkt $loc_kurtosis - | $dir_mrtrix_dev/tensor2metric -  -dkt $loc_kurtosis -mk $loc_mean_kurt -ak $loc_axial_kurt -rk $loc_radial_kurt -force
}