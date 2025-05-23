#!/bin/bash

# Function to check if NVIDIA driver is installed
check_nvidia_driver() {
  if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA driver is already installed."
  else
    echo "NVIDIA driver not found. Please install the NVIDIA driver first."
    exit 1
  fi
}

# Install Docker if not already installed
install_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    
    # Update package list
    sudo apt update
    
    # Install Docker
    sudo apt install -y docker.io
    
    # Enable Docker service
    sudo systemctl enable --now docker
    
    # Add user to Docker group (this may require a logout/login)
    sudo usermod -aG docker $USER
    
    echo "Docker installed successfully."
  else
    echo "Docker is already installed."
  fi
}

# Install NVIDIA Container Toolkit
install_nvidia_docker() {
  echo "Installing NVIDIA Container Toolkit..."
  
  # Add NVIDIA repository and key
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  
  # Update package list and install nvidia-docker2
  sudo apt update
  sudo apt install -y nvidia-docker2
  
  # Restart Docker service
  sudo systemctl restart docker
  
  echo "NVIDIA Container Toolkit installed successfully."
}

# Configure Docker to use NVIDIA runtime by default
configure_docker_runtime() {
  echo "Configuring Docker to use NVIDIA runtime by default..."
  
  # Create or edit the Docker daemon.json
  sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
EOF'
  
  # Restart Docker service to apply changes
  sudo systemctl restart docker
  
  echo "Docker configured to use NVIDIA runtime by default."
}

# Run all functions
main() {
  check_nvidia_driver
  install_docker
  install_nvidia_docker
  configure_docker_runtime
  
  echo "Setup complete. You can now run GPU-accelerated containers!"
}

# Execute the main function
main
