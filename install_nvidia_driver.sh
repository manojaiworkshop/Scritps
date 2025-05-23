sudo apt purge 'nvidia*'
sudo apt autoremove
sudo apt clean
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt update
sudo apt install nvidia-driver-550
sudo reboot

# for kernal 6 nvidia-driver-550 is best suitable