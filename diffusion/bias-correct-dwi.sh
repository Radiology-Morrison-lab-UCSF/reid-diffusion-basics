source $(dirname "$BASH_SOURCE[0]")/../file-or-gz.sh

BiasCorrect() {
    local loc_eddyCorrected=$1
    local loc_mask=$2
    local loc_out=$3

    if file_or_gz_exists $loc_out; then
        echo $loc_out found. Bias Correction Skipped
        return 0
    fi

    dwibiascorrect ants $loc_eddyCorrected $loc_out -mask $loc_mask
}