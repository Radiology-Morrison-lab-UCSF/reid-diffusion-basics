load_fsl(){
local current_script="$(realpath "${BASH_SOURCE[0]}")"
local dir_sourceTop=$(dirname "$current_script")/
export FSLDIR="$dir_sourceTop"/fsl/
export PATH="$PATH":"$FSLDIR"

. ${FSLDIR}/etc/fslconf/fsl.sh
}

load_fsl

# FSL Setup
FSLDIR=/home/lreid/source-local/reid-diffusion-basics/fsl
PATH=${FSLDIR}/share/fsl/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh
