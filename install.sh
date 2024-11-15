#!/bin/bash

dir_script="$(dirname "$(readlink -f "$0")")"/
source "${dir_script}/install/install-fsl.sh"
source "${dir_script}/install/install-python.sh"

set -e


check_prerequisites () {
    # Nothing to do at this point
    return
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install unzip using apt-get
install_unzip() {
    if ! command_exists unzip; then
        sudo apt-get update
        sudo apt-get install -y unzip
    fi
}


install_homebrew() {
    # Check if Homebrew is already installed
    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed."
        return 0
    fi

    # Install Homebrew
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Check if installation was successful
    if [ $? -eq 0 ]; then
        echo "Homebrew installation successful."
    else
        echo "Failed to install Homebrew."
        exit 1
    fi
}

build_mrtrix3tissue() {

    local install_dir="$1"
    local directory="${install_dir}/MRtrix3Tissue"

    if [ -f $directory/bin/ss3t_csd_beta1 ]; then
        echo "MRtrix3Tissue installation found. Delete $directory and re-run script to reinstall"
        return 0
    fi

    install_mrtrix_dependencies

    # Check if the directory exists and is not empty
    if [ ! -d "$directory" ] || [ -z "$(ls -A "$directory")" ]; then
        # Clone the repository if the directory doesn't exist or is empty
        git clone https://github.com/3Tissue/MRtrix3Tissue.git "$directory"
    else
        echo "Git clone skipped: Directory $directory already exists and is not empty."
    fi

    cd $directory



    if [ ! -d Eigen ]; then
        # This is not compatible with new Eigen, so put an old version of eigen in the 
        # directory and point to it, rather than universally with homebrew
        git clone https://gitlab.com/libeigen/eigen.git
        cd eigen
        git checkout 3.3.9
        cd ..
    fi

    # For maximal performance, swap x86-64-v3 for native but this will limit 
    # this running properly on many machines on the UCSF cluster because they
    # are highly heterogeneous, including within the same partition
    #export ARCH=native
    export ARCH=x86-64-v3
    EIGEN_CFLAGS="-isystem $(pwd)/eigen" ./configure -nogui
    ./build
}

build_mrtrix3Dev() {

    local install_dir="$1"
    local directory="${install_dir}/MRtrix3Src"
    local installTo="${install_dir}/mrtrix3-dev"

    if [ -d $installTo ]; then
        echo "MRtrix3 Dev installation found. Delete $installTo and re-run script to reinstall"
        return 0
    fi

    install_mrtrix_dependencies

    # Check if the directory exists and is not empty
    if [ ! -d "$directory" ] || [ -z "$(ls -A "$directory")" ]; then
        # Clone the repository if the directory doesn't exist or is empty
        git clone --depth 1 --branch dev https://github.com/MRtrix3/MRtrix3.git "$directory"
    else
        echo "Git clone skipped: Directory $directory already exists and is not empty."
    fi

    cd $directory

    # create the make files. Note that we set the git path to nothing so that it does not try
    # to compare the mrtrix base version to the current tag, as in the dev arm it refuses to build this was
    cmake  -B build -G Ninja -D CMAKE_INSTALL_PREFIX="$installTo" -D MRTRIX_BUILD_GUI=OFF -D GIT_EXECUTABLE=
    # build
    cmake --build build
    cmake --install build

    echo "Installed mrtrix dev to $installTo:"
    ls $installTo

    cd "$install_dir"
    echo "Removing $directory"
    rm -rf $directory
}
install_hd_bet() {
    # Python must be activated first(!)

    if [ -d HD-BET ]; then
        echo "HD-BET installation found. Delete HD-BET directory and re-run script to reinstall"
        return 0
    fi

    echo "Installing HD-BET"

    git clone https://github.com/MIC-DKFZ/HD-BET

    cd HD-BET
    python3 -m ensurepip
    python -m pip install -e .
    echo "folder_with_parameter_files = os.path.join(os.path.dirname(os.path.abspath(__file__)), \"models\")" >> HD_BET/paths.py

    # Download the model ahead of time
    mkdir models
    wget -O models/0.model https://zenodo.org/record/2540695/files/0.model?download=1 
    wget -O models/1.model https://zenodo.org/record/2540695/files/1.model?download=1 
    wget -O models/2.model https://zenodo.org/record/2540695/files/2.model?download=1 
    wget -O models/3.model https://zenodo.org/record/2540695/files/3.model?download=1 
    wget -O models/4.model https://zenodo.org/record/2540695/files/4.model?download=1 

    cd ..
    
}

install_ants() {

    local install_dir="$1"

    if [ -d ants ]; then
        echo "Ants installation found. Delete ants directory and re-run script to reinstall"
        return 0
    fi

    if [[ $(uname) == "Darwin" ]]; then
        curl -L https://github.com/ANTsX/ANTs/releases/download/v2.5.1/ants-2.5.1-macos-14-ARM64-clang.zip -o ants.zip
        unzip ants.zip
        mv ants-2.5.1-arm ants
    else

        install_unzip

        wget -O ants.zip https://github.com/ANTsX/ANTs/releases/download/v2.5.1/ants-2.5.1-ubuntu-22.04-X64-gcc.zip 
        unzip ants.zip
        mv ants-2.5.1 ants
    fi

    rm ants.zip

}


install_mrtrix_dependencies() {
    if [[ $(uname) == "Darwin" ]]; then
        echo "macOS detected."

        while true; do
            echo "qt5 pkg-config libtiff fftw libpng will now be installed via brew. Continue (y/n)?"
            read -r answer

            case "$answer" in
                [Yy])
                    echo "Installing..."
                    break
                    ;;
                [Nn])
                    echo "Installation aborted."
                    exit 1
                    ;;
                *)
                    echo "Invalid input. Please enter 'y' or 'n'."
                    ;;
            esac
        done

        install_homebrew

        brew install qt5 pkg-config libtiff fftw libpng ninja-build

        # Add Qt’s binaries to your path
        export PATH='brew --prefix'/opt/qt5/bin:$PATH

    else
        sudo apt-get update
        sudo apt-get install git g++ python3.10 python3.10-dev \
                                     python3-pip python3.10-venv \
                                     zlib1g-dev libqt5opengl5-dev \
                                     libgl1-mesa-dev libfftw3-dev \
                                     libtiff5-dev libpng-dev \
                                     libeigen3-dev cmake \
                                     ninja-build \
                                     -y
    fi
}



print_help() {
    echo "Usage: $0 <directory> [--no-sudo]"
    echo "If <directory> is provided this will be installed to that folder instead of the directory it is currently in"
    echo "  --no-sudo  If specified, the script will not use sudo."
}

parse_args() {
    # Initialize variables
    install_to=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-sudo)
            no_sudo="$1"
            shift
            ;;
            *)
            if [ -z "$file_path" ]; then
                install_to="$1"
                shift
            else
                # If there are more than one positional arguments
                echo "Error: Unexpected argument '$1'."
                display_help
                exit 1
            fi
            ;;
        esac
    done

}

install() {

    install_dir=$(pwd)
    echo "Installing to $install_dir"
    
    check_prerequisites

    install_python

    install_hd_bet

    install_ants "$install_dir"

    build_mrtrix3tissue "$install_dir"

    build_mrtrix3Dev "$install_dir"
    
    install_fsl
    
    sudo apt-get install dcm2niix -y
    
    echo "Install Complete"
}


parse_args "$@"

# Ensure we are in the dir of this script
cd $dir_script


if [ ! -z "$install_to" ]; then
    # Copy all files from current directory to the specified directory
    mkdir -p "$install_to"
    cp -r ./* "$install_to"

    # Execute install there instead
    cd "$install_to"
    ./install.sh "$no_sudo"
    exit 0
fi

echo "----"
echo $no_sudo

if [ ! -z "$no_sudo" ]; then
    source ./install/no-sudo.sh
fi

install
