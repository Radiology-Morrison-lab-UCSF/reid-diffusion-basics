source file-or-gz.sh
function CalcTensors {
    loc_in=$(gz-filepath-if-only-gz-found "$1")
    loc_mask=$(gz-filepath-if-only-gz-found "$2")
    loc_fa=$(gz-filepath-if-only-gz-found "$3")
    loc_md=$(gz-filepath-if-only-gz-found "$4")

    if [ -f "$loc_fa" ] && \
       [ -f "$loc_md" ] ]; then
        return 
    fi

    dwi2tensor -mask $loc_mask $loc_in - | tensor2metric - -mask $loc_mask -fa $loc_fa -adc $loc_md -force
}