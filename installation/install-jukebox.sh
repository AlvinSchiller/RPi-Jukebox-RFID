#!/usr/bin/env bash
# One-line install script for the Jukebox Version 3
#
# To install, simply execute
# cd; bash <(wget -qO- https://raw.githubusercontent.com/MiczFlor/RPi-Jukebox-RFID/future3/develop/installation/install-jukebox.sh)
#
# If you want to get a specific branch or a different repository (mainly for developers)
# you may specify them like this
# cd; GIT_USER='MiczFlor' GIT_BRANCH='future3/develop' bash <(wget -qO- https://raw.githubusercontent.com/MiczFlor/RPi-Jukebox-RFID/future3/develop/installation/install-jukebox.sh)
#
export LC_ALL=C

# Set Repo variables if not specified when calling the script
GIT_USER=${GIT_USER:-"MiczFlor"}
GIT_BRANCH=${GIT_BRANCH:-"future3/main"}

# Constants
GIT_REPO_NAME="RPi-Jukebox-RFID"
GIT_URL="https://github.com/${GIT_USER}/${GIT_REPO_NAME}"
echo GIT_BRANCH $GIT_BRANCH
echo GIT_URL $GIT_URL

CURRENT_USER="${SUDO_USER:-$(whoami)}"
CURRENT_USER_GROUP=$(id -gn "$CURRENT_USER")
HOME_PATH=$(getent passwd "$CURRENT_USER" | cut -d: -f6)

INSTALLATION_PATH="${HOME_PATH}/${GIT_REPO_NAME}"
INSTALL_ID=$(date +%s)
INSTALLATION_LOGFILE="${HOME_PATH}/INSTALL-${INSTALL_ID}.log"

INSTALLATION_PATH_PREV="${HOME_PATH}/${GIT_REPO_NAME}-${INSTALL_ID}"
USE_PREV_INSTALL_CONFIG=false

# Manipulate file descriptor for logging
_setup_logging(){
    if [ "$CI_RUNNING" == "true" ]; then
        exec 3>&1 2>&1
    else
        exec 3>&1 1>>"${INSTALLATION_LOGFILE}" 2>&1 || { echo "ERROR: Cannot create log file."; exit 1; }
    fi
    echo "Log start: ${INSTALL_ID}"
}

# Function to log to both console and logfile
print_lc() {
  local message="$1"
  echo -e "$message" | tee /dev/fd/3
}

# Function to log to logfile only
log() {
  local message="$1"
  echo -e "$message"
}

# Function to run a command where the output will be logged to both console and logfile
run_and_print_lc() {
  "$@" | tee /dev/fd/3
}

# Function to log to console only
print_c() {
  local message="$1"
  echo -e "$message" 1>&3
}

# Function to clear console screen
clear_c() {
  clear 1>&3
}

# Generic emergency error handler that exits the script immediately
# Print additional custom message if passed as first argument
# Examples:
#   a command || exit_on_error
#   a command || exit_on_error "Execution of command failed"
exit_on_error () {
  print_lc "\n****************************************"
  print_lc "ERROR OCCURRED!
A non-recoverable error occurred.
Check install log for details:"
  print_lc "$INSTALLATION_LOGFILE"
  print_lc "****************************************"
  if [[ -n $1 ]]; then
    print_lc "$1"
    print_lc "****************************************"
  fi
  log "Abort!"
  exit 1
}

# Check if current distro is a 32-bit version
# Support for 64-bit Distros has not been checked (or precisely: is known not to work)
# All Raspberry Pi OS versions report as machine "armv6l" or "armv7l", if 32-bit (even the ARMv8 cores!)
_check_os_type() {
  local os_type=$(uname -m)

  print_lc "\nChecking OS type '$os_type'"

  if [[ $os_type == "armv7l" || $os_type == "armv6l" ]]; then
    print_lc "  ... OK!\n"
  else
    print_lc "ERROR: Only 32-bit operating systems are supported. Please use a 32-bit version of Raspberry Pi OS!"
    print_lc "For Pi 4 models or newer running a 64-bit kernels, also see this: https://github.com/MiczFlor/RPi-Jukebox-RFID/issues/2041"
    exit 1
  fi
}

_check_existing_installation() {
    if [[ -e "${INSTALLATION_PATH}" ]]; then
        print_c "############## EXISTING INSTALLATION FOUND ##############

If you want to keep your settings, continue with 'y'
- the installation folder will be moved to '${INSTALLATION_PATH_PREV}' as backup
- the current install configuration will be used to perform the installation
- your './shared/' folder will be copied to the new installation
- any other file changes have to be copied manually

Else you will be prompted with the installation options
- the installation folder will be moved to '${INSTALLATION_PATH_PREV}' as backup
- NOTE: previously installed features will currently not be removed!

Keep your current settings? [y/N]"
        read -r response
        case "$response" in
            [yY][eE][sS]|[yY])
                if [[ -f "${INSTALL_CONFIG_CURRENT}" ]]; then
                    USE_PREV_INSTALL_CONFIG=true
                else
                    print_lc "ERROR: No '${INSTALL_CONFIG_FILENAME} found. Can't use configuration."
                    print_lc "       Choosing installation options required!"
                fi
                ;;
            *)
                ;;
        esac
        log "USE_PREV_INSTALL_CONFIG=${USE_PREV_INSTALL_CONFIG}"
        mv -f "$INSTALLATION_PATH" "$INSTALLATION_PATH_PREV"
        log "Moved existing installation to '${INSTALLATION_PATH_PREV}'"
    fi
}

_load_installation_config() {
    if [[ "${USE_PREV_INSTALL_CONFIG}" == true ]]; then
        cp -f "${INSTALLATION_PATH_PREV}/${INSTALL_CONFIG_FILENAME}" "${INSTALL_CONFIG_CURRENT}"
        source "${INSTALL_CONFIG_CURRENT}" || exit_on_error
    fi
}

_download_jukebox_source() {
  log "#########################################################"
  print_c "Downloading Phoniebox software from Github ..."
  print_lc "Download Source: ${GIT_URL}/${GIT_BRANCH}"

  cd "${HOME_PATH}" || exit_on_error "ERROR: Changing to home dir failed."
  wget -qO- "${GIT_URL}/tarball/${GIT_BRANCH}" | tar xz
  # Use case insensitive search/sed because user names in Git Hub are case insensitive
  local git_repo_download=$(find . -maxdepth 1 -type d -iname "${GIT_USER}-${GIT_REPO_NAME}-*")
  log "GIT REPO DOWNLOAD = $git_repo_download"
  GIT_HASH=$(echo "$git_repo_download" | sed -rn "s/.*${GIT_USER}-${GIT_REPO_NAME}-([0-9a-fA-F]+)/\1/ip")
  # Save the git hash for this particular download for later git repo initialization
  log "GIT HASH = $GIT_HASH"
  if [[ -z "${git_repo_download}" ]]; then
    exit_on_error "ERROR: Couldn't find git download."
  fi
  if [[ -z "${GIT_HASH}" ]]; then
    exit_on_error "ERROR: Couldn't determine git hash from download."
  fi
  mv "$git_repo_download" "$GIT_REPO_NAME"
  log "\nDONE: Downloading Phoniebox software from Github"
  log "#########################################################"
}

_load_sources() {
    # Load / Source dependencies
    for i in "${INSTALLATION_PATH}"/installation/includes/*; do
        source "$i" || exit_on_error
    done

    for j in "${INSTALLATION_PATH}"/installation/routines/*; do
        source "$j" || exit_on_error
    done
}

### SETUP LOGGING
_setup_logging

### CHECK PREREQUISITE
_check_os_type

### RUN INSTALLATION
log "Current User: $CURRENT_USER"
log "User home dir: $HOME_PATH"

_check_existing_installation
_download_jukebox_source
cd "${INSTALLATION_PATH}" || exit_on_error "ERROR: Changing to install dir failed."
_load_sources
_load_installation_config

welcome
run_with_timer install
finish
