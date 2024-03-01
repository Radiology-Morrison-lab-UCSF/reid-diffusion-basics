function SkullStripDWI {
    loc_in=$1
    loc_out=$2
    if [ ! -f $loc_out ]; then
        dwi2mask $loc_in $loc_out
    fi
}