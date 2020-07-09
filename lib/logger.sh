#
# dotfiles/lib/logger.sh
#
# Contains various logging functions for this project.
#
# Author: Luis Love
#

# Directory containing all logs for this project
declare -r LOG_DIR="$HOME/.dotfiles/log"

# Log directory names
declare -r LOG_BREW_FORMULAE_DIR="brew_formulae"
declare -r LOG_BREW_CASKS_DIR="brew_casks"
declare -r LOG_APT_PACKAGE_DIR="apt_packages"

# Log file names
declare -r LOG_APT="apt.log"
declare -r LOG_BREW="brew.log"
declare -r LOG_DOTFILES="dotfiles.log"
declare -r LOG_INSTALL="install.log"

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
    local logFile="$LOG_DIR/$1/$2"

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


_createLog() {
    local fileDir="$LOG_DIR/$1"
    local file="$fileDir/$2"

    if _logExists "$1" "$2"; then
        return 0
    fi

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
    _createLog "$1" "$LOG_APT"
}


createLogBrew() {
    local formulaDir="$LOG_DIR/$1/$LOG_BREW_FORMULAE_DIR"
    local caskDir="$LOG_DIR/$1/$LOG_BREW_CASKS_DIR"

    if ! _createLog "$1" "$LOG_BREW"; then
        return 1
    fi

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


_logMessage() {
    local fileDir="$LOG_DIR/$1"
    local file="$fileDir/$2"
    local message="$3"
    local numTabs="$4"
    local printMessage="$5"

    if ! _logExists "$1" "$2"; then
        return 1
    fi

    # Indicates how much indentation will occur when displaying message.
    local buffer=""
    for ((i = 0; i < "$numTabs"; ++i)); do
        buffer="$buffer    "
    done
    
    local line=""
    while IFS= read -r line; do
        [[ ! "$line" == *\n ]] && line="$line\n"

        if "$printMessage"; then
            printf "$buffer$line"
        fi
        printf "$(date +"%m-%d-%Y (%H:%M:%S)"): $buffer$line" >> "$file"	
    done <<< "$message"
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
