#!/bin/bash

# Function to check if a package is installed, and install it if it is not
install_if_missing() {
    if ! dpkg -l | grep -qw "$1"; then
        echo "Package $1 is not installed. Installing..."
        sudo apt-get install -y "$1"
    else
        echo "Package $1 is already installed."
    fi
}

# Update package list
echo "Updating package list..."
sudo apt-get update

# Check and install required packages
install_if_missing "build-essential"
install_if_missing "libpcre3"
install_if_missing "libpcre3-dev"
install_if_missing "zlib1g"
install_if_missing "zlib1g-dev"
install_if_missing "libssl-dev"
install_if_missing "curl"
install_if_missing "wget"
install_if_missing "unzip"

# Get the latest version number from the Nginx download page
echo "Fetching the latest Nginx version..."
latest_version=$(curl -s http://nginx.org/en/download.html | grep -oP 'nginx-\K[0-9.]+(?=\.tar\.gz)' | head -1)

# Form the download URL
download_url="http://nginx.org/download/nginx-${latest_version}.tar.gz"

# Download the latest version of Nginx
echo "Downloading Nginx version $latest_version..."
wget $download_url

# Extract the downloaded tarball
echo "Extracting Nginx..."
tar -xzvf "nginx-${latest_version}.tar.gz"

# Change into the extracted directory
cd "nginx-${latest_version}"

# Configure the build options
echo "Configuring Nginx build options..."
./configure --with-http_ssl_module --with-pcre

# Compile and install Nginx
echo "Compiling and installing Nginx..."
make
sudo make install

# Start Nginx server
echo "Starting Nginx..."
sudo /usr/local/nginx/sbin/nginx

# Check if Nginx is running
echo "Verifying Nginx installation..."
if pgrep nginx > /dev/null
then
    echo "Nginx installation successful and running."
else
    echo "Nginx installation failed or Nginx is not running."
fi