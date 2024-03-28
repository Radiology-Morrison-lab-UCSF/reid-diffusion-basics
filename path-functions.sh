#!/bin/bash

# Function to add '/' to a variable if it doesn't end with it already
add_slash_if_needed() {
    local var="$1"

    # Check if the variable ends with '/'
    if [[ "$var" != */ ]]; then
        var="$var/"
    fi

    echo "$var"
}