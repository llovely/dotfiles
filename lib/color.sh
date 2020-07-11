#
# dotfiles/lib/color.sh
#
# Contains various colors to be used in shell output. Supported colors
# and modifiers include the following:
#
#   Text Modifiers:
#       - Reset
#       - Bold
#
#   Colors:
#       - Black
#       - White
#       - Purple
#       - Blue
#       - Cyan
#       - Green
#       - Yellow
#       - Orange
#       - Red
#
# Author: Luis Love
#

tput setaf 1 > /dev/null 2>&1
if [[ "$?" -eq "0" ]]; then
    # Resets colors
    tput sgr0 > /dev/null 2>&1

    declare -r reset="$(tput sgr0)"
    declare -r bold="$(tput bold)"
    declare -r black="$(tput setaf 0)"
    declare -r white="$(tput setaf 15)"
    declare -r purple="$(tput setaf 90)"
    declare -r blue="$(tput setaf 153)"
    declare -r cyan="$(tput setaf 37)"
    declare -r green="$(tput setaf 71)"
    declare -r yellow="$(tput setaf 228)"
    declare -r orange="$(tput setaf 166)"
    declare -r red="$(tput setaf 196)"
else
    declare -r reset="\e[0m"
    declare -r bold=""
    declare -r black="\e[1;30m"
    declare -r white="\e[1;37m"
    declare -r purple="\e[1;35m"
    declare -r blue="\e[1;34m"
    declare -r cyan="\e[1;36m"
    declare -r green="\e[1;32m"
    declare -r yellow="\e[1;33m"
    declare -r orange="\e[1;33m"
    declare -r red="\e[1;31m"
fi
