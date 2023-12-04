#!/usr/bin/env bash

set_ssh_qos() {
    if [ "$DISABLE_SSH_QOS" == true ] ; then
        local sshd_config="/etc/ssh/sshd_config"
        local ssh_config="/etc/ssh/ssh_config"
        local ssh_qos_entry="IPQoS 0x00 0x00\n"

        # The latest version of SSH installed on the Raspberry Pi 3 uses QoS headers, which disagrees with some
        # routers and other hardware. This causes immense delays when remotely accessing the RPi over ssh.
        log "  Set SSH QoS to best effort"
        if grep -qiw "${ssh_qos_entry}" "${sshd_config}"; then
            log "    Skipping ${sshd_config}. Already set up!"
        else
            echo -e "${ssh_qos_entry}" | sudo tee -a "${sshd_config}"
        fi

        if grep -qiw "${ssh_qos_entry}" "${ssh_config}"; then
            log "    Skipping ${sshd_config}. Already set up!"
        else
            echo -e "${ssh_qos_entry}" | sudo tee -a "${ssh_config}"
        fi
    fi
}
