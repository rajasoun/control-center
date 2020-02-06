#!/usr/bin/env sh

ssh-keyscan -H "$VM_IP" >> "$HOME/.ssh/known_hosts"
ansible -i /inventory/hosts -m ping all