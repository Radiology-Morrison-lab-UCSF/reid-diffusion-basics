install_python() {

    sudo apt-get install python3.10 python3.10-venv -y

    # Create a Python virtual environment
    if [ ! -d env ]; then
        # Create a Python virtual environment
        python3 -m venv env
    fi


    # Activate the virtual environment
    chmod -R 700 ./env/bin/
    source env/bin/activate


}
