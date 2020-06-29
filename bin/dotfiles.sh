#!/usr/bin/env bash
#
# dotfiles/bin/dotfiles.sh
#
# Installs relevant dotfiles in the user's $HOME directory using symbolic
# links.
#
# Author: Luis Love
#

source "$HOME/.dotfiles/lib/logger"

# Option Flags
silentMode=false
invalidArg=false
displayHelp=false
logProvided=false

logID=""	# Log Identifier

# Number of operations necessary to install all dotfiles
declare -i operationsCompleted=0
declare -i TOTAL_OPERATIONS=7

# Dotfiles and corresponding directories
DOTFILES_DIR="$HOME/.dotfiles/shell"
CONFIG_DOTFILES_DIR="$HOME/.dotfiles/config"
PRIVATE_DOTFILE="private"
declare -a DOTFILES=( "bash_profile" \
                      "bashrc" \
                      "$PRIVATE_DOTFILE" )
declare -a CONFIG_DOTFILES=( "inputrc" \
                             "vimrc" \
                             "git/gitconfig" )


usage() {
    local script=${0##*/}
    echo "Usage: ./$script [-hs] [-l <log_ID>]"
    echo
    echo "Description:"
    echo
    echo "    This script will install/overwrite various dotfiles in one's \$HOME directory, '$HOME'. If present, the"
    echo "    following dotfiles will be overwritten with symbolic links:"
    echo
    for file in "${DOTFILES[@]}" "${CONFIG_DOTFILES[@]}"; do
        echo "        $HOME/.${file##*/}"
    done
    echo
    echo "Options:"
    echo
    echo "    -h            Prints this help message. If combined with other options, it will be ignored."
    echo "    -s            Silent Mode. No output is printed to stdout or stderr (logging is still preserved)."
    echo "                  Returns 0 if all operations completed successfully; otherwise, 1 if partial or"
    echo "                  complete failure."
    echo "    -l <log_ID>   Provides the log_ID; aids in identifying where the associated logged output from"
    echo "                  running this script is located. See below for more info."
    echo
    echo "Log Identifier (log_ID):"
    echo
    echo "    This identifier specifies which directory the logged output from running this script will be located in."
    echo "    This option is typically used when storing the logged output from multiple scripts that conform to this"
    echo "    style of identifier."
    echo
    echo "    The directory and file containing the logged output will be:"
    echo
    echo "        $LOG_DIR/<log_ID>/$LOG_DOTFILES"
    echo
    echo "    The <log_ID> must conform to the following pattern:"
    echo
    echo "        log_MONTH-DAY-YEAR_HOUR-MINUTE-SECOND"
    echo
    echo "    The extended regex representation of the above is as follows:"
    echo
    echo "        $VALID_LOG_ID_REGEX"
    echo
    echo "Notes:"
    echo
    echo "    If multiple '-l' options are provided, only the last log_ID will be used; for example:"
    echo
    echo "        ./dotfiles -s -l log_05-17-2020_13-17-37 -l log_05-17-2020_14-58-09 -l log_05-18-2020-00-01-48"
    echo "                                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^"
    echo "                                                                            Only this log_ID will be used"
}


exitMessage() {
    echo
    echo "$operationsCompleted of $TOTAL_OPERATIONS Operations Successfully Completed."
    echo
    echo "The last successfully completed operation is shown above (If any)."
    echo
    echo "The logged output from running this script can be found at: $LOG_DIR/$logID/$LOG_DOTFILES\n"
}


parseArgs() {
    while [[ ! OPTIND -gt "$#" ]]; do
        while getopts ":hsl:" opt; do
            case $opt in
                s)	# Silent Mode selected
                    silentMode=true
                    ;;
                l)	# log_ID provided
                    logProvided=true
                    logID="$OPTARG"
                    ;;
                h)	# Help Message requested
                    displayHelp=true
                    ;;
                *)	# Unknown Option provided
                    invalidArg=true
                    ;;
            esac
        done

        # Invalid Arguments are skipped.
        if [[ ! OPTIND -gt "$#" ]]; then
            invalidArg=true
            (( ++OPTIND ))
        fi
    done
}


shouldPrint() {
    if ! $silentMode; then
        echo true;
    else
        echo false;
    fi
}


###############################################################################
#						Parse and Process Provided Options
###############################################################################

parseArgs "$@"

# Ignore displaying usage info if help option is included with other options
($silentMode || $invalidArg || $logProvided) && displayHelp=false

# Display Help Message and exit
if $displayHelp; then
    usage
    exit 1
fi

# Generate Log Identifier, if one hasn't already been provided
if ! $logProvided; then
    logID="$(createLogID)"
fi

# Verify Log Identifier, exit if invalid
if ! validLogID "$logID"; then
    if ! $silentMode; then
        echo "ERROR: Invalid log_ID generated/provided. See usage (-h option) for correct format."
    fi
    exit 1;
fi

# Create the log file, exit if the file couldn't be created
if ! createLogDotfiles "$logID"; then
    if ! $silentMode; then
        echo "ERROR: Unable to create log file '$LOG_DIR/$logID/$LOG_DOTFILES'."
    fi
    exit 1
fi

# Invalid option / argument was provided, display Help Message and exit
if $invalidArg; then
    logDotfiles "$logID" "ERROR: Invalid option/argument provided!\n" "$(shouldPrint)"
    logDotfiles "$logID" "$(usage $0)" "$(shouldPrint)"
    exit 1
fi


###############################################################################
#								Install Dotfiles
###############################################################################

logDotfiles "$logID" "Creating file '$DOTFILES_DIR/$PRIVATE_DOTFILE'...\n" \
            "$(shouldPrint)"
if [[ -f "$DOTFILES_DIR/$PRIVATE_DOTFILE" ]]; then
    logDotfiles "$logID" "    File already exists. (Success)\n\n" "$(shouldPrint)"
    (( ++operationsCompleted ))
else
    rm -rf "$DOTFILES_DIR/$PRIVATE_DOTFILE"
    (
    cat <<-\__EOF__
        #!/usr/bin/env bash
        #
        # dotfiles/shell/private
        #
        # File intended to store the user's private commands and credentials.
        # The contents of this file will not be commited, and is sourced only
        # by the bashrc file.

	__EOF__
    ) > "$DOTFILES_DIR/$PRIVATE_DOTFILE"
    if [[ ! -f "$DOTFILES_DIR/$PRIVATE_DOTFILE" ]]; then
        logDotfiles "$logID" \
                    "    Failed to create '$DOTFILES_DIR/$PRIVATE_DOTFILE'.\n\n" \
                    "$(shouldPrint)"
        logDotfiles "$logID" "$(exitMessage)" "$(shouldPrint)"
        exit 1
    else
        logDotfiles "$logID" "Completed.\n\n" "$(shouldPrint)"
        (( ++operationsCompleted ))
    fi
fi


logDotfiles "$logID" \
            "Creating Symbolic Links to relevant dotfiles in directory '$HOME'...\n" \
            "$(shouldPrint)"

# Shell Dotfiles
for dotfile in "${DOTFILES[@]}"; do
    symlinkMsg="Symlink: ${HOME}/.${dotfile} -> ${DOTFILES_DIR}/${dotfile}"
    if ln -sf "${DOTFILES_DIR}/${dotfile}" "${HOME}/.${dotfile}"; then
        logDotfiles "$logID"  "    $symlinkMsg (Success)\n" "$(shouldPrint)"
        (( ++operationsCompleted ))
    else
        logDotfiles "$logID" "$symlinkMsg (Failed)\n" "$(shouldPrint)"
        logDotfiles "$logID" "$(exitMessage)" "$(shouldPrint)"
        exit 1
    fi
done

# Config Dotfiles
for dotfile in "${CONFIG_DOTFILES[@]}"; do
    symlinkMsg="Symlink: ${HOME}/.${dotfile##*/} -> ${CONFIG_DOTFILES_DIR}/${dotfile}"
    if ln -sf "${CONFIG_DOTFILES_DIR}/${dotfile}" "${HOME}/.${dotfile##*/}"; then
        logDotfiles "$logID" "    $symlinkMsg (Success)\n" "$(shouldPrint)"
        (( ++operationsCompleted ))
    else
        logDotfiles "$logID"  "    $symlinkMsg (Failed)\n" "$(shouldPrint)"
        logDotfiles "$logID" "$(exitMessage)" "$(shouldPrint)"
        exit 1
    fi
done

logDotfiles "$logID" "$(exitMessage)" "$(shouldPrint)"
