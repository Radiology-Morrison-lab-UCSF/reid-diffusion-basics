#!/bin/bash

# Create a Python virtual environment
if [ ! -d env ]; then
    # Create a Python virtual environment
    python3 -m venv env
fi


# Activate the virtual environment
source env/bin/activate