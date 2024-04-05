#!/bin/bash
set -e

original_cwd=$(pwd)
source_dir=$(dirname "$0")
cd $source_dir
source path-functions.sh
source exe-paths.sh
source file-or-gz.sh
source t1-processing/structural-paths.sh
source diffusion/dwi-paths.sh


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
    echo "Processes the T1 and registers it to the diffusion images"
    echo "Process diffusion images first!"
    echo "See install.sh for installation"
    echo 
    echo "Usage: t1-to-diffusion.sh --study-dir <study-directory> --subj <subject-id>"
    echo "where <study-directory> is the absolute path to the a directory laid out like so:"
    echo "<study-directory>/dicoms/<subject-id>/t1/*.dcm"
    echo "<study-directory>/diffusion/<subject-id>/fa.nii.gz"
    echo "<study-directory>/diffusion/<subject-id>/mask.mif.gz"
    echo ""
    echo "Example output:"
    echo "/home/lee/my-study/structurals/mike-jones/t1.nii.gz"
    echo "/home/lee/my-study/structurals/mike-jones/t1-brainmask.nii.gz"
    echo "/home/lee/my-study/structurals/mike-jones/t1-in-diffusion-space.nii.gz"
    echo "/home/lee/my-study/structurals/mike-jones/t1-to-diffusion.mat"
    echo "etc"
    exit 1
fi


t1-processing/prepare-t1.sh --study-dir $dir_top --subj $subj

# SetStructuralPaths sets up the paths we need for t1s, brainmasks, etc
SetStructuralPaths $dir_top $subj
SetDWIPaths $dir_top $subj

if [ ! $(file_or_gz_exists $loc_t1_to_dwi $loc_t1_dwi_space) ]; then
    cd $dir_processed_structurals

    loc_moving=$(gz-filepath-if-only-gz-found "$loc_t1_n4")
    loc_moving_mask=$(gz-filepath-if-only-gz-found "$loc_t1_brainmask")
    loc_fixed=$(gz-filepath-if-only-gz-found "$loc_fa")

    loc_fixed_mask=$(mktemp)
    mv $loc_fixed_mask $loc_fixed_mask.nii
    loc_fixed_mask=$loc_fixed_mask.nii
    trap "rm $loc_fixed_mask" EXIT
    mrconvert --force $(gz-filepath-if-only-gz-found "$loc_dwimask") $loc_fixed_mask

    antsRegistration \
        -d 3 \
        -o [t1-to-diffusion,t1-in-diffusion-space.nii.gz,] \
        --interpolation Linear \
        --winsorize-image-intensities [0.005,0.995] \
        --use-histogram-matching 1 \
        --masks [$loc_fixed_mask,$loc_moving_mask] \
        --initial-moving-transform [$loc_fixed,$loc_moving,1] \
        --metric MI[$loc_fixed,$loc_moving,1,64,Regular,0.5] \
        --transform Rigid[0.1] \
        --convergence 1000x500x200x100 \
        --smoothing-sigmas 8x4x2x1vox \
        --shrink-factors 8x4x2x1 \
        --float \
        --random-seed 123456 \
        --verbose
    
    mv t1-to-diffusion0GenericAffine.mat $loc_t1_to_dwi
fi
    