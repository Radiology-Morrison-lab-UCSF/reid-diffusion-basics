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

    if file_or_gz_exists "$loc_kurtosis"; then
        echo "$loc_kurtosis" found. Calculation skipped
        return 
    fi
    dwi2tensor -mask $loc_mask $loc_in -dkt $loc_kurtosis - > /dev/null
}