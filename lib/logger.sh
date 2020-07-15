#
# dotfiles/lib/logger.sh
#
# Contains various logging functions for this project.
#
# Author: Luis Love
#

# Directory containing all logs for this project
declare -r LOG_DIR="${HOME}/.dotfiles/log"

# Log directory names
declare -r LOG_BREW_FORMULAE_DIR="brew_formulae"
declare -r LOG_BREW_CASKS_DIR="brew_casks"
declare -r LOG_APT_PACKAGES_DIR="apt_packages"
declare -r LOG_APT_PACKAGE_REPOS_DIR="apt_repos"
declare -r LOG_SNAP_PACKAGES_DIR="snap_packages"

# Log file names
declare -r LOG_APT="apt.log"
declare -r LOG_BREW="brew.log"
declare -r LOG_DOTFILES="dotfiles.log"
declare -r LOG_INSTALL="install.log"
declare -r LOG_SHELL="bashShell.log"
declare -r LOG_SNAP="snap.log"

# Regex of a valid name for a directory containing the above log files
declare -r VALID_LOG_ID_REGEX='^log_[0-9]{2}-[0-9]{2}-[0-9]{4}_[0-9]{2}-[0-9]{2}-[0-9]{2}$'


createLogID() {
    local logID="log_$(date +"%m-%d-%Y_%H-%M-%S" 2> /dev/null)"

    [[ "$logID" == "log_" ]] && return 1
    echo "$logID"

    return 0
}


validLogID() {
    [[ "$1" =~ $VALID_LOG_ID_REGEX ]]
}


_logExists() {
    local logFile="${LOG_DIR}/${1}/${2}"

    [[ -f "$logFile" && -r "$logFile" && -w "$logFile" ]]
}


logAptExists() {
    _logExists "$1" "$LOG_APT"
}


logBrewExists() {
    _logExists "$1" "$LOG_BREW"
}


logDotfilesExists() {
    _logExists "$1" "$LOG_DOTFILES"
}


logInstallExists() {
    _logExists "$1" "$LOG_INSTALL"
}


logShellExists() {
    _logExists "$1" "$LOG_SHELL"
}


logSnapExists() {
    _logExists "$1" "$LOG_SNAP"
}


_createLog() {
    local fileDir="${LOG_DIR}/${1}"
    local file="${fileDir}/${2}"

    # Creates logging directory, if it doesn't exist
    if [[ ! -d "$fileDir" ]]; then
        mkdir -p "$fileDir" > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi
    
    # Creates log file, if it doesn't exist
    if [[ ! -f "$file" ]]; then
        rm -rf "$file"
        (touch "$file" && chmod u+rw "$file") > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi

    return 0
}


createLogApt() {
    local packageDir="${LOG_DIR}/${1}/${LOG_APT_PACKAGES_DIR}"
    local repoDir="${LOG_DIR}/${1}/${LOG_APT_PACKAGE_REPOS_DIR}"

    _createLog "$1" "$LOG_APT" > /dev/null 2>&1 
    [[ "$?" -ne "0" ]] && return 1

    # Creates logging directory for Homebrew Formulae, if it doesn't exist
    if [[ ! -d "$packageDir" ]]; then
        mkdir -p "$packageDir" > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi

    # Creates logging directory for Homebrew Casks, if it doesn't exist
    if [[ ! -d "$repoDir" ]]; then
        mkdir -p "$repoDir" > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi

    return 0 
}


createLogBrew() {
    local formulaDir="${LOG_DIR}/${1}/${LOG_BREW_FORMULAE_DIR}"
    local caskDir="${LOG_DIR}/${1}/${LOG_BREW_CASKS_DIR}"

    _createLog "$1" "$LOG_BREW" > /dev/null 2>&1 
    [[ "$?" -ne "0" ]] && return 1

    # Creates logging directory for Homebrew Formulae, if it doesn't exist
    if [[ ! -d "$formulaDir" ]]; then
        mkdir -p "$formulaDir" > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi

    # Creates logging directory for Homebrew Casks, if it doesn't exist
    if [[ ! -d "$caskDir" ]]; then
        mkdir -p "$caskDir" > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi

    return 0
}


createLogDotfiles() {
    _createLog "$1" "$LOG_DOTFILES"
}


createLogInstall() {
    _createLog "$1" "$LOG_INSTALL"
}


createLogShell() {
    _createLog "$1" "$LOG_SHELL"
}


createLogSnap() {
    local packageDir="${LOG_DIR}/${1}/${LOG_SNAP_PACKAGES_DIR}"

    _createLog "$1" "$LOG_SNAP" > /dev/null 2>&1 
    [[ "$?" -ne "0" ]] && return 1

    # Creates logging directory for SNAP packages, if it doesn't exist
    if [[ ! -d "$packageDir" ]]; then
        mkdir -p "$packageDir" > /dev/null 2>&1 
        [[ "$?" -ne "0" ]] && return 1
    fi

    return 0
}


_logMessage() {
    local file="${LOG_DIR}/${1}/${2}"
    local message="$3"
    local -i numTabs="$4"
    local printMessage="$5"
    local buffer=""
    local line=""
    local -i i=0

    # Verifies if log exists
    _logExists "$1" "$2" > /dev/null 2>&1
    [[ "$?" -ne "0" ]] && return 1    

    # Indicates how much indentation will occur per line of a log output
    for ((i = 0; i < "$numTabs"; ++i)); do
        buffer="${buffer}    "
    done
    
    # Process multiline messages by line
    while IFS= read -r line; do
        # Print message to stdout
        if "$printMessage"; then
            printf '%s\n' "$buffer$line"
        fi

        # Log message to log file
        printf '%s\n' "$(date +"%m-%d-%Y (%H:%M:%S)"): ${buffer}${line}" >> "$file"	
    done <<< "$message"

    return 0
}


logApt() {
    _logMessage "$1" "$LOG_APT" "$2" "$3" "$4"
}


logBrew() {
    _logMessage "$1" "$LOG_BREW" "$2" "$3" "$4"
}


logDotfiles() {
    _logMessage "$1" "$LOG_DOTFILES" "$2" "$3" "$4"
}


logInstall() {
    _logMessage "$1" "$LOG_INSTALL" "$2" "$3" "$4"
}


logShell() {
    _logMessage "$1" "$LOG_SHELL" "$2" "$3" "$4"
}


logSnap() {
    _logMessage "$1" "$LOG_SNAP" "$2" "$3" "$4"    
}
