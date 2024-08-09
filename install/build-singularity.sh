#!/bin/bash
# Must be executed from the directory in which it resides
# See build-singularity-slurm.sh
set -ex


buildDir="/tmp/build-reid-imaging/"
export APPTAINER_CACHEDIR="${buildDir}cache/"
export APPTAINER_TMPDIR="${buildDir}tmp/"
export APPTAINER_BINDPATH=""

mkdir -p "$APPTAINER_CACHEDIR"
mkdir -p "$APPTAINER_TMPDIR"

apptainer build ../reid-diffusion-basics.sif Singularity.def

rm -r "$buildDir"