load_fsl(){
local current_script="$(realpath "${BASH_SOURCE[0]}")"
local dir_sourceTop=$(dirname "$current_script")/
export FSLDIR="$dir_sourceTop"/fsl/
export PATH="$PATH":"$FSLDIR":"$FSLDIR/share/fsl/bin"

. ${FSLDIR}/etc/fslconf/fsl.sh
}

load_fsl
