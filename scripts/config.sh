#!/bin/bash

# Note
# - Manual options chosen
#   - locale en_US.UTF-8 -> option 97
#
#sudo apt-get install -y unzip
# Cleanup previous run
#sudo rm -rf ./chroot

# This script provides common customization options for the ISO
# 
# Usage: Copy this file to config.sh and make changes there.  Keep this file (default_config.sh) as-is
#   so that subsequent changes can be easily merged from upstream.  Keep all customiations in config.sh

# The version of Ubuntu to generate.  Successfully tested LTS: bionic, focal, jammy, noble
# See https://wiki.ubuntu.com/DevelopmentCodeNames for details
#export TARGET_UBUNTU_VERSION="focal"
export TARGET_UBUNTU_VERSION="noble"

# The Ubuntu Mirror URL. It's better to change for faster download.
# More mirrors see: https://launchpad.net/ubuntu/+archivemirrors
export TARGET_UBUNTU_MIRROR="http://us.archive.ubuntu.com/ubuntu/"

# The packaged version of the Linux kernel to install on target image.
# See https://wiki.ubuntu.com/Kernel/LTSEnablementStack for details
export TARGET_KERNEL_PACKAGE="linux-generic"

# The file (no extension) of the ISO containing the generated disk image,
# the volume id, and the hostname of the live environment are set from this name.
export TARGET_NAME="ubuntu-from-scratch"

# The text label shown in GRUB for booting into the live environment
export GRUB_LIVEBOOT_LABEL="Try Ubuntu FS without installing"

# The text label shown in GRUB for starting installation
export GRUB_INSTALL_LABEL="Install Ubuntu FS"

# Packages to be removed from the target system after installation completes succesfully
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

# Package customisation function.  Update this function to customize packages
# present on the installed system.
function customize_image_ORIG() {
    # install graphics and desktop
    apt-get install -y \
        plymouth-themes \
        ubuntu-gnome-desktop \
        ubuntu-gnome-wallpapers

    # useful tools
    apt-get install -y \
        clamav-daemon \
        terminator \
        apt-transport-https \
        curl \
        vim \
        nano \
        less

    # purge
    apt-get purge -y \
        transmission-gtk \
        transmission-common \
        gnome-mahjongg \
        gnome-mines \
        gnome-sudoku \
        aisleriot \
        hitori
}

# New customization function
function customize_image() {

    #apt update
	    
    apt-get install -y \
        wget \
        curl \
        htop \
	jq \
	yq \
	git \
	make \
	bash \
	python3-venv \
	sshpass \
	ansible \
	openssh-server

    
    #systemctl enable ssh

}

setup_ansible() {
    # Create the ansible user (non-interactive)
    useradd -m -s /bin/bash ansible  # -s /bin/bash sets the shell
    
    # Set a password for the ansible user (non-interactive)
    #echo "ansible_password" | passwd --stdin ansible  # Replace with a strong password

    # Add the ansible user to the sudo group (if needed)
    usermod -aG sudo ansible

    # Create the virtual environment (as ansible user, non-interactive)
    su - ansible -c "python3 -m venv ansible_venv && source ansible_venv/bin/activate && pip install ansible && deactivate"

    # Create the .ssh directory for the ansible user
    mkdir -p /home/ansible/.ssh
    chown ansible:ansible /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh
    # Allow SSH to the ansible account
    mkdir -p /home/ansible/.ssh
    chown ansible:ansible /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh
    touch /home/ansible/.ssh/authorized_keys
    chown ansible:ansible /home/ansible/.ssh/authorized_keys 
    chmod 600 /home/ansible/.ssh/authorized_keys
    github_users=("pwyoung" "philwyoungatinsight") # Array of GitHub usernames
    for user in "${github_users[@]}"; do
	curl -s "https://api.github.com/users/$user/keys" | jq -r '.[].key' | while read key; do
	    if ! grep -q "$key" /home/ansible/.ssh/authorized_keys; then
		echo "$key" >> /home/ansible/.ssh/authorized_keys
	    fi
	done
    done

    # Disable password authentication (non-interactive)
    #sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    ## OR, if the line doesn't exist:
    ## sed -i '/^#*PasswordAuthentication/a PasswordAuthentication no' /etc/ssh/sshd_config
    
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
