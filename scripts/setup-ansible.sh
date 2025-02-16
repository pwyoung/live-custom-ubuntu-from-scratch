#!/bin/bash

if [[ $UID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi


function add_packages() {
    apt update
	    
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
    
    systemctl enable ssh
}

function setup_ansible() {
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

add_packages
setup_ansible

