
function CleanupTmpDir {
    rm -rf $dir_tmp
}

function ConvertRaw() {
    loc_out=$3
    if [ -e $loc_out ]; then
        return
    fi

    dir_tmp=`mktemp -d`
    trap CleanupTmpDir EXIT
    
    loc_temp_ap=$dir_tmp"temp_ap.mif"
    loc_temp_pa=$dir_tmp"temp_pa.mif"

    dcm2niix -o $dir_tmp $1
    mrconvert -force $dir_tmp/*.nii* -json_import $dir_tmp/*.json -fslgrad $dir_tmp/*bvec $dir_tmp/*bval $loc_temp_ap

    rm $dir_tmp/*
    dcm2niix -o $dir_tmp $2
    mrconvert -force $dir_tmp/*.nii* -json_import $dir_tmp/*.json -fslgrad $dir_tmp/*bvec $dir_tmp/*bval $loc_temp_pa
    
    mrcat $loc_temp_ap $loc_temp_pa $loc_out
    mrinfo $loc_out 

    CleanupTmpDir
}