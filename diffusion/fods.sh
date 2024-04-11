source ../file-or-gz.sh
source ../exe-paths.sh

function SSMTFOD() {
    local loc_in=$(gz-filepath-if-only-gz-found "$1")
    local loc_mask=$(gz-filepath-if-only-gz-found "$2")
    local dir_out=$(gz-filepath-if-only-gz-found "$3")

    local loc_resp_wm=$dir_out/response-wm.txt
    local loc_resp_gm=$dir_out/response-gm.txt
    local loc_resp_csf=$dir_out/response-csf.txt
    local loc_fod_wm=$dir_out/fod-wm.mif.gz
    local loc_fod_gm=$dir_out/fod-gm.mif.gz
    local loc_fod_csf=$dir_out/fod-csf.mif.gz

    if file_or_gz_exists "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf" "$loc_fod_wm" "$loc_fod_gm" "$loc_fod_csf"; then
        echo "FODs found. Calculation skipped"
        return 0
    fi
    
    if ! file_or_gz_exists "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf"; then
        dwi2response dhollander "$loc_in" "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf"
    fi
    
    $loc_python $dir_mrtrix_3tissue/ss3t_csd_beta1 -mask $loc_mask "$loc_in" "$loc_resp_wm" "$loc_fod_wm" "$loc_resp_gm" "$loc_fod_gm" "$loc_resp_csf" "$loc_fod_csf"
 
}

function MSMTFOD() {
    local loc_in=$(gz-filepath-if-only-gz-found "$1")
    local loc_mask=$(gz-filepath-if-only-gz-found "$2")
    local dir_out=$(gz-filepath-if-only-gz-found "$3")

    local loc_resp_wm=$dir_out/response-wm.txt
    local loc_resp_gm=$dir_out/response-gm.txt
    local loc_resp_csf=$dir_out/response-csf.txt
    local loc_fod_wm=$dir_out/fod-wm.mif
    local loc_fod_gm=$dir_out/fod-gm.mif
    local loc_fod_csf=$dir_out/fod-csf.mif

    if file_or_gz_exists "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf" "$loc_fod_wm" "$loc_fod_gm" "$loc_fod_csf"; then
        echo "FODs found. Calculation skipped"
        return 0
    fi
    
    if ! file_or_gz_exists "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf"; then
        dwi2response dhollander "$loc_in" "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf"
    fi

    dwi2fod msmt_csd $loc_in -mask $loc_mask "$loc_resp_wm" "$loc_fod_wm" "$loc_resp_gm" "$loc_fod_gm" "$loc_resp_csf" "$loc_fod_csf"
  
}