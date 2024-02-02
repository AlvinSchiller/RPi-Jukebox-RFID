_setup_login_message() {
    if [[ "${USE_PREV_INSTALL_CONFIG}" == true ]]; then
        rm -rf "${SHARED_PATH}"
        cp -f "${INSTALLATION_PATH_PREV}/${SHARED_FOLDERNAME}" "${SHARED_PATH}"
    fi
}

_setup_login_message() {
    sudo cp -f "${INSTALLATION_PATH}/resources/system/99-rpi-jukebox-rfid-welcome" "/etc/update-motd.d/99-rpi-jukebox-rfid-welcome"
}

_run_setup_postinstall() {
    _setup_login_message
}

setup_postinstall() {
    run_with_log_frame _run_setup_postinstall "Post install"
}

