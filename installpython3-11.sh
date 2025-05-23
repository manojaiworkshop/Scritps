#!/bin/bash

# Exit on any error
set -e

# Update package index
sudo apt update

# Install required dependencies
sudo apt install -y software-properties-common

# Add the deadsnakes PPA (contains newer Python versions)
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# Install Python 3.11
sudo apt install -y python3.11 python3.11-venv python3.11-dev

# Set python3.11 as default if needed (optional)
# sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Verify installation
python3.11 --version
