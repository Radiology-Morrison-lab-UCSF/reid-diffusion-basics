function DenoiseAndGibbs {
    loc_in=$1
    loc_out=$2
    if [ ! -f $loc_out ]; then 
        dwidenoise $loc_in - | mrdegibbs - $loc_out -axes 0,1
    fi
}