#
# dotfiles/lib/apt.sh
#
# Contains various functions for aiding in the installation and processing
# of programs from linux distros using the APT package manager.
#
# Author: Luis Love
#

source "${HOME}/.dotfiles/lib/logger.sh"


updateApt() {
    sudo apt-get update
}


upgradeApt() {
    sudo apt-get upgrade -y
}


searchAptPackage() {
    local packageRegex="$1" # Extended regex representation of desired package
    local output=""

    output="$(
              sudo apt-cache search --names-only "^${packageRegex}$"
             )"

    [[ ! -z "$output" ]]
}


isAptPackageInstalled() {
    sudo dpkg -l "$1" > /dev/null 2>&1
}


installAptPackage() {
    isAptPackageInstalled "$1" > /dev/null 2>&1
    if [[ "$?" -eq "0" ]]; then
        sudo apt-get upgrade "$1" --yes
    else
        sudo apt-get install "$1" --yes
    fi
}


getAptPackage() {
    local logID="$1"
    local package="$2"
    local packageDir="$3"
    local -i baseIndent="$4"
    local logFile=""
    local output=""

    logMsg "Installing '${package}' Package...\n" "$baseIndent"


    logMsg "Updaing package repo lists...\n" "$((${baseIndent} + 1))"

    updateApt 2> /dev/null | \
    while IFS= read -r output; do
        logMsg "$output" "$((${baseIndent} + 2))"
    done

    if [[ "${PIPESTATUS[0]}" -eq "0" ]]; then
        logMsg "Update Completed. (Success)\n" "$((${baseIndent} + 2))"
    else
        logMsg "Update Failed. (Failed)\n" "$((${baseIndent} + 2))"
        return 1
    fi
    

    # Log file for specified package
    logFile="${LOG_DIR}/${logID}/${packageDir}/${package}.log"

    # Removes existing log file, if present
    if [[ -e "$logFile" ]]; then
        logMsg "Removing existing log file '${logFile}'...\n" "$((${baseIndent} + 1))"
        rm -rf "$logFile" > /dev/null 2>&1
        if [[ ! -e "$logFile" ]]; then
            logMsg "Existing log removed. (Success)\n" "$((${baseIndent} + 2))" 
        else
            logMsg "Failed to remove existing log. (Failed)\n" "$((${baseIndent} + 2))"
            return 1
        fi
    fi

    # Creates log file
    logMsg "Creating log file for '${package}' package...\n" "$((${baseIndent} + 1))"
    (touch "$logFile" && chmod u+rw "$logFile") > /dev/null 2>&1
    if [[ "$?" -eq "0" ]]; then
        logMsg "Log file created. (Success)\n" "$((${baseIndent} + 2))"
    else
        logMsg "Unable to create log for this package. (Failed)\n" "$((${baseIndent} + 2))"
        return 1
    fi


    logMsg "Specific log output for '${package}' can be found at: ${logFile}\n" "$((${baseIndent} + 1))"

    
    # Install/Update Package
    isAptPackageInstalled "$package" > /dev/null 2>&1
    if [[ "$?" -eq "0" ]]; then
        logMsg "'${package}' already installed, upgrading...\n" "$((${baseIndent} + 1))"
    fi
    installAptPackage "$package" 2>&1 | tee "$logFile" | \
    while IFS= read -r output; do
        logMsg "$output" "$((${baseIndent} + 2))"
    done

    if [[ "${PIPESTATUS[0]}" -eq "0" ]]; then
        logMsg "Package installation completed. (Success)\n" "$((${baseIndent} + 1))"
    else
        logMsg "Package installation failed. (Failed)\n" "$((${baseIndent} + 1))"
        return 1
    fi

    return 0
}
