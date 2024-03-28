source file-or-gz.sh

function SkullStripDWI {
    loc_in=$(gz-filepath-if-only-gz-found "$1")
    loc_out=$2
    if [ ! -f $loc_out ]; then
        dwi2mask $loc_in $loc_out
    fi
}