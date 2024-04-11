#!/bin/bash

set -e

source_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))
cd $source_dir
source ../path-functions.sh
source ../file-or-gz.sh
source ../exe-paths.sh
source convert-raw.sh
source structural-paths.sh
source ../diffusion/dwi-paths.sh
source $source_dir/../atlases/mni-paths.sh


# Parse command line arguments
cd $original_cwd
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --study-dir)
        dir_top=$(realpath "$2")
        shift # past argument
        shift # past value
        ;;
        --subj)
        subj="$2"
        shift # past argument
        shift # past value
        ;;
        *)  # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

cd $source_dir

# Check if required arguments are provided
if [ -z "$dir_top" ] || [ -z "$subj" ]; then
    echo "Non-linearly registers the T1 to MNI space"
    echo "Process diffusion and T1 images first!"
    echo "See install.sh for installation"
    echo 
    echo "Usage: t1-to-mni.sh --study-dir <study-directory> --subj <subject-id>"
    exit 1
fi

# SetStructuralPaths sets up the paths we need for t1s, brainmasks, etc
SetStructuralPaths $dir_top $subj
SetDWIPaths $dir_top $subj

if $(file_or_gz_exists $loc_t1_to_mni_affine $loc_t1_to_mni_nonrigid $loc_t1_mni_space); then
    echo "Registration found. Exiting"
    exit
fi
    
SetAtlasPaths

cd $dir_processed_structurals
loc_moving=$(GzFilepathIfOnlyGzFound "$loc_t1_n4")
loc_moving_mask=$(GzFilepathIfOnlyGzFound "$loc_t1_brainmask")
loc_fixed=$loc_mni_t1
loc_fixed_mask=$loc_mni_mask

antsRegistration \
    -d 3 \
    -o [t1-to-mni,$loc_t1_mni_space] \
    --interpolation Linear \
    --winsorize-image-intensities [0.005,0.995] \
    --use-histogram-matching 1 \
    --masks [$loc_fixed_mask,$loc_moving_mask] \
    --initial-moving-transform [$loc_fixed,$loc_moving,1] \
    --transform Rigid[0.1] \
    --metric MI[$loc_fixed,$loc_moving,1,64,Regular,0.5] \
    --convergence 1000x500x200x100 \
    --smoothing-sigmas 3x2x1x0vox \
    --shrink-factors 8x4x2x1 \
    --transform Affine[0.1] \
    --metric MI[$loc_fixed,$loc_moving,1,64,Regular,0.5] \
    --convergence 1000x500x200x100 \
    --smoothing-sigmas 3x2x1x0vox \
    --shrink-factors 8x4x2x1 \
    --transform SyN[0.1,3,0] \
    --metric CC[$loc_fixed,$loc_moving,1,4] \
    --convergence 100x70x50x20 \
    --smoothing-sigmas 3x2x1x0vox \
    --shrink-factors 8x4x2x1 \
    --float \
    --random-seed 123456 \
    --verbose

mv t1-to-mni0GenericAffine.mat $loc_t1_to_mni_affine
mv t1-to-mni1Warp.nii.gz $loc_t1_to_mni_nonrigid
mv t1-to-mni1InverseWarp.nii.gz $loc_t1_to_mni_nonrigid_inverse
