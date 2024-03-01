function CleanupTmpDir {
    rm -rf $dir_tmp
}

function EddyCorrect {
    loc_in=$1
    loc_out=$2
    if [ -f $loc_out ]; then
        return
    fi

    dir_tmp=`mktemp -d`
    trap CleanupTmpDir EXIT

    loc_b0s=$dir_tmp"/b0s.mif"
    loc_dwis=$dir_tmp"/dwis.mif"
    dwiextract -force $loc_in -bzero $loc_b0s
    dwiextract -force $loc_in -no_bzero $loc_dwis
    dwifslpreproc $loc_in $loc_out -rpe_header -se_epi $loc_b0s -align_seepi
    
    CleanupTmpDir
}