#!/bin/bash

# Create a Python virtual environment
if [ ! -d env ]; then
    # Create a Python virtual environment
    python3 -m venv env
fi


# Activate the virtual environment
chmod -R 700 ./env/bin/
source env/bin/activate