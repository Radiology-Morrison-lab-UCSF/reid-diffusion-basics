function CalcTensors {
    loc_in=$1
    loc_mask=$2
    loc_fa=$3
    loc_md=$4

    if [ -f "$loc_fa" ] && \
       [ -f "$loc_md" ] ]; then
        return 
    fi

    dwi2tensor -mask $loc_mask $loc_in - | tensor2metric - -mask $loc_mask -fa $loc_fa -adc $loc_md -force
}