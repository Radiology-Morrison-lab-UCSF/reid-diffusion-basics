

function SSMTFOD() {
    loc_in=$1
    dir_out=$2

    loc_resp_wm=$dir_out/response-wm.txt
    loc_resp_gm=$dir_out/response-gm.txt
    loc_resp_csf=$dir_out/response-csf.txt
    loc_fod_wm=$dir_out/fod-wm.mif
    loc_fod_gm=$dir_out/fod-gm.mif
    loc_fod_csf=$dir_out/fod-csf.mif

    if [ -f "$loc_resp_wm" ] && \
       [ -f "$loc_resp_gm" ] && \
       [ -f "$loc_resp_csf" ] && \
       [ -f "$loc_fod_wm" ] && \
       [ -f "$loc_fod_gm" ] && \
       [ -f "$loc_fod_csf" ]; then
        return 
    fi
    
    if [ ! -f "$loc_resp_wm" ] || \
       [ ! -f "$loc_resp_gm" ] || \
       [ ! -f "$loc_resp_csf" ]; then
        dwi2response dhollander $loc_in $dir_out/response-wm.txt $dir_out/response-gm.txt $dir_out/response-csf.txt    
    fi
    
    # Activate the virtual environment
    source exe-paths.sh
    source $loc_activate_python

    $loc_python $dir_mrtrix_3tissue/ss3t_csd_beta1 $loc_in $dir_out/response-wm.txt $dir_out/fod-wm.mif $dir_out/response-gm.txt $dir_out/fod-gm.mif $dir_out/response-csf.txt $dir_out/fod-csf.mif
 
}