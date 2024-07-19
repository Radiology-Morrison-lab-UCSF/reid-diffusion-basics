#!/bin/bash


check_prerequisites () {
    if [ -z "$FSLDIR" ] || [ ! -d "$FSLDIR" ]; then
        echo "FSLDIR is not found or is not a valid directory."
        echo "This script does not handle installing FSL. You must install FSL yourself."
        exit -1
    fi

    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is not found. Please install Python 3 then re-run this script."
        exit 1
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

    install_dependencies

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
        cd Eigen
        git checkout 3.3.9
        cd ..
    fi

    # try again with appropriate flags:
    export ARCH=native
    EIGEN_CFLAGS="-isystem $(pwd)/eigen" ./configure
    ./build
}

build_mrtrix3Dev() {

    local directory="MRtrix3Src"
    local installTo="$(pwd)/mrtrix3-dev"

    if [ -f $installTo ]; then
        echo "MRtrix3 Dev installation found. Delete $installTo and re-run script to reinstall"
        return 0
    fi

    install_dependencies

    # Check if the directory exists and is not empty
    if [ ! -d "$directory" ] || [ -z "$(ls -A "$directory")" ]; then
        # Clone the repository if the directory doesn't exist or is empty
        git clone --depth 1 --branch dev https://github.com/MRtrix3/MRtrix3.git "$directory"
    else
        echo "Git clone skipped: Directory $directory already exists and is not empty."
    fi

    cd $directory

    cmake -B build -DCMAKE_INSTALL_PREFIX=$installTo
    cmake --build build
    cmake --install build
}
install_hd_bet() {
    # Python must be activated first(!)

    if [ -d HD-BET ]; then
        echo "HD-BET installation found. Delete HD-BET directory and re-run script to reinstall"
        return 0
    fi

    git clone https://github.com/MIC-DKFZ/HD-BET

    cd HD-BET
    python -m pip install -e .
    echo "folder_with_parameter_files = os.path.join(os.path.dirname(os.path.abspath(__file__)), \"models\")" >> HD_BET/paths.py
    cd ..
    
}

install_ants() {

    if [ -d ants ]; then
        echo "Ants installation found. Delete ants directory and re-run script to reinstall"
    fi

    if [[ $(uname) == "Darwin" ]]; then
        curl -L https://github.com/ANTsX/ANTs/releases/download/v2.5.1/ants-2.5.1-macos-14-ARM64-clang.zip -o ants.zip
        unzip ants.zip
        mv ants-2.5.1-arm ants
    else
        wget https://github.com/ANTsX/ANTs/releases/download/v2.5.1/ants-2.5.1-ubuntu-22.04-X64-gcc.zip ants.zip
        unzip ants.zip
    fi

    rm ants.zip

}

setup_python() {

    # Create a Python virtual environment
    if [ ! -d env ]; then
        # Create a Python virtual environment
        python3 -m venv env
    fi


    # Activate the virtual environment
    chmod -R 700 ./env/bin/
    source env/bin/activate
}

# Ensure we are in the dir of this script
dir_script="$(dirname "$(readlink -f "$0")")"/
cd $dir_script

install_dependencies() {
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
                                     zlib1g-dev libqt4-opengl-dev \
                                     libgl1-mesa-dev libfftw3-dev \
                                     libtiff5-dev libpng-dev \
                                     eigen
        exit 1
    fi
}

check_prerequisites

setup_python

install_ants

build_mrtrix3tissue

build_mrtrix3Dev

install_hd_bet

echo "Install Complete"