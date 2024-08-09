install_fsl() {

    set -ex

    local install_source_dir=$(realpath $(dirname "$BASH_SOURCE[0]"))
    local source_dir=$(realpath "$install_source_dir/../")

    local fsldir="$source_dir"/fsl

    if [ -d "$fsldir" ]; then
        echo "Local FSLDIR found. Installation skipped"
        return 0
    fi

    if [ ! -z "$FSLDIR" ] || [ -d "$FSLDIR" ]; then
        echo "Systemwide FSLDIR found. Installation skipped"
        return 0
    fi

    echo Installing FSL as "$fsldir" was not found and FSLDIR is unset

    python3 "$install_source_dir/fslinstaller.py" --skip_registration --dest "$fsldir" --homedir "$source_dir" --no_matlab "$@"

}
