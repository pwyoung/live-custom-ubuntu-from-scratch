#!/bin/bash

echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/"${USER}-nopasswd"

#visudo -c -f /etc/sudoers.d/"${USER}-nopasswd"

