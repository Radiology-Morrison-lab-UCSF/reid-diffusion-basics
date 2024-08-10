# Source this file to replace sudo with a function that just runs the provided arguments normally
sudo() {

    if [ "$#" -eq 0 ]; then
        echo "No command provided."
        exit 1
    fi

    # Run the command with the provided arguments
    "$@"
}
