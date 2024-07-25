#!/bin/bash

source install/install-fsl.sh
source install/install-python.sh

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

    local directory="MRtrix3Tissue"

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

    local start=$(pwd)
    cd $directory



    if [ ! -d Eigen ]; then
        # This is not compatible with new Eigen, so put an old version of eigen in the 
        # directory and point to it, rather than universally with homebrew
        git clone https://gitlab.com/libeigen/eigen.git
        cd eigen
        git checkout 3.3.9
        cd ..
    fi

    export ARCH=native
    EIGEN_CFLAGS="-isystem $(pwd)/eigen" ./configure -nogui
    ./build

    cd $start
}

build_mrtrix3Dev() {

    local directory="MRtrix3Src"
    local installTo="$(pwd)/mrtrix3-dev"
    local start=$(pwd)

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
    cmake -B build -D CMAKE_INSTALL_PREFIX="$installTo" -D MRTRIX_BUILD_GUI=OFF -D GIT_EXECUTABLE=
    # build
    cmake --build build
    cmake --install build

    cd $start
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
    wget -O HD-BET/HD_BET/0.model https://zenodo.org/record/2540695/files/0.model?download=1 

    cd ..
    
}

install_ants() {

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


# Ensure we are in the dir of this script
dir_script="$(dirname "$(readlink -f "$0")")"/
cd $dir_script

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

        brew install qt5 pkg-config libtiff fftw libpng

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
                                     -y
    fi
}



print_help() {
    echo "Usage: $0 <directory>"
    echo "If <directory> is provided this will be installed to that folder instead of the directory it is currently in"
}


install(){
    
    check_prerequisites

    install_python

    build_mrtrix3Dev

    build_mrtrix3tissue
    
    sudo apt-get install dcm2niix -y

    install_hd_bet
    
    install_fsl

    install_ants

    echo "Install Complete"
}

if [ $# -eq 0 ]; then
    install
    exit 0
fi

if [ $# -ne 1 ]; then
    print_help
    exit 1
fi

# Check if the argument starts with '-'
if [[ $1 == -* ]]; then
    print_help
    exit 1
fi

# Copy all files from current directory to the specified directory
mkdir -p "$1"
cp -r ./* "$1"

# Execute install there instead
cd "$1"
./install.sh
