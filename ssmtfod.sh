source file-or-gz.sh

function SSMTFOD() {
    loc_in=$(gz-filepath-if-only-gz-found "$1")
    dir_out=$(gz-filepath-if-only-gz-found "$2")

    loc_resp_wm=$dir_out/response-wm.txt
    loc_resp_gm=$dir_out/response-gm.txt
    loc_resp_csf=$dir_out/response-csf.txt
    loc_fod_wm=$dir_out/fod-wm.mif.gz
    loc_fod_gm=$dir_out/fod-gm.mif.gz
    loc_fod_csf=$dir_out/fod-csf.mif.gz

    if file_or_gz_exists "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf" "$loc_fod_wm" "$loc_fod_gm" "$loc_fod_csf"; then
        return 
    fi
    
    if ! file_or_gz_exists "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf"; then
        dwi2response dhollander "$loc_in" "$loc_resp_wm" "$loc_resp_gm" "$loc_resp_csf"
    fi
    
    # Activate the virtual environment
    source exe-paths.sh
    source $loc_activate_python

    $loc_python $dir_mrtrix_3tissue/ss3t_csd_beta1 "$loc_in" "$loc_resp_wm" "$loc_fod_wm" "$loc_resp_gm" "$loc_fod_gm" "$loc_resp_csf" "$loc_fod_csf"
 
}