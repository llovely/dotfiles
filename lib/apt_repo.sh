#
# dotfiles/lib/apt_repo.sh
#
# Installs repos and updates package lists to install packages. Each
# function corresponds to installation of a desired package.
#
# Author: Luis Love
#

source "${HOME}/.dotfiles/lib/apt.sh"


_logMsgAppend() {
    local message="$1"
    local indent="$2"
    local logFile="$3"

    # Log message goes to stdout AND is appended to the log file
    if ! "$silentMode"; then
        logMsg "$message" "$indent" | tee -a "$logFile"
    # Log message is appended to the log file
    else
        logMsg "$message" "$indent" >> "$logFile"
    fi

    return 0
}


_acquirePackageRepoInfo() {
    local logFile="$1"
    local cmd="$2"
    local baseIndent="$3"
    local output=""

    (eval $cmd) 2>&1 | \
    while IFS= read -r output; do
        _logMsgAppend "$output" "$((${baseIndent} + 1))" "$logFile"
    done
    [[ "${PIPESTATUS[0]}" -ne "0" ]] && return 1

    return 0
}


_installPackage() {
    local logFile="$1"
    local logID="$2"
    local package="$3"
    local packageDir="$4"
    local -i baseIndent="$5"

    # Output goes to stdout AND is appended to the log file
    if ! "$silentMode"; then 
        getAptPackage "$logID" "$package" "$packageDir" "$baseIndent" 2>&1 | tee -a "$logFile"
    # Output is appended to the log file
    else
        getAptPackage "$logID" "$package" "$packageDir" "$baseIndent" 2>&1 >> "$logFile"
    fi

    return 0
}


#
# Use this function as a template!
#
# Copy this function, then only THREE alterations need to be made to install 
# any other basic package repo. They are:
#
#   1) Name the function: aptRepoInstall_<identifier>
#
#      The identifier NEEDS TO MATCH what is listed in the
#      'apt_package_repos' file (dotfiles/install/apt/apt_package_repos).
#
#   2) Replace the elements of the 'repo_cmds' array with the commands
#      necessary for adding package repositories (as seen below).
#
#   3) Replace the elements in the 'packages' array with the packages
#      needed to be installed. Several packages can be listed, if need be.
#
aptRepoInstall_sbt() {
    local logFile="$1"
    local logID="$2"
    local packageDir="$3"
    local -i baseIndent="$4"
    local cmd=""
    local package=""

    # List of commands to install package repositories
    local -a repo_cmds=(
                        'echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list' \
                        'curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add'
                       )

    # Packages to be installed
    local -a packages=(
                        "sbt"
                      )

    # Enables output to be piped out if silent mode is enabled
    pipeToggle=true
    trap 'pipeToggle=false' RETURN
    

    # Installs package repositories
    _logMsgAppend "Acquiring package repo info...\n" "$baseIndent" "$logFile"
    for cmd in "${repo_cmds[@]}"; do
        _acquirePackageRepoInfo "$logFile" "$cmd" "$baseIndent"
        [[ "$?" -ne "0" ]] && return 1
    done


    # Install packages
    for package in "${packages[@]}"; do
        _installPackage "$logFile" "$logID" "$package" "$packageDir" "$baseIndent" 
        if [[ "$?" -ne "0" ]]; then
            _logMsgAppend "Package repo installation failed. (Failed)" "$baseIndent"  "$logFile"
            return 1
        fi
    done

    _logMsgAppend "Package repo installation completed. (Success)" "$baseIndent"  "$logFile"

    return 0
}


###############################################################################
#         Place Additional Package Repo Installation Functions Below
###############################################################################
