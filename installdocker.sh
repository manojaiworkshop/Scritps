#!/bin/bash

# Exit on any error
set -e

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
echo "Adding Docker’s GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "Updating package index with Docker repository..."
sudo apt-get update

# Install Docker Engine
echo "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to the docker group (to run Docker without sudo)
echo "Adding current user to the docker group..."
sudo usermod -aG docker $USER

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version

# Test Docker with a hello-world container
echo "Running a test container..."
sudo docker run hello-world

echo "Docker installation completed successfully!"
echo "Please log out and log back in to apply the Docker group changes."
echo "After logging back in, you can run Docker commands without sudo."