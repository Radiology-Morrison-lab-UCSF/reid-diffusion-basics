#!/bin/bash

set -e

source_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))
source $source_dir/file-or-gz.sh
source $source_dir/diffusion/dwi-paths.sh
source $source_dir/t1-processing/structural-paths.sh
source $source_dir/exe-paths.sh

MniRoiToDwi(){
    # Requires SetStructuralPaths an dSetDWIPaths have already been run
    local roi=$(GzFilepathIfOnlyGzFound "$1")
    local out=$(GzFilepathIfOnlyGzFound "$2")

    if file_or_gz_exists $out; then
        echo $out found. Creation skipped
        return
    fi
    
    # NB datatype of int below allows labels
    antsApplyTransforms \
        -d 3 \
        --input $roi \
        --reference-image $loc_fa \
        --output $out \
        --interpolation MultiLabel \
        --output-data-type int \
        --transform $loc_t1_to_dwi \
        --transform [$loc_t1_to_mni_affine,1] \
        --transform $loc_t1_to_mni_nonrigid_inverse
}