#
# Various escape sequences used in shell text output.
#
# This script MUST be sourced into an existing shell function to work
# properly; this is due to the use of 'local' variables.
#

# General Text Attributes
local ES_RESET
local ES_BOLD
local ES_DIM
local ES_STANDOUT
local ES_UNDERSCORE
local ES_BLINK
local ES_REVERSE
local ES_HIDDEN

# Foreground Colors
local ES_FG_BLACK
local ES_FG_RED
local ES_FG_GREEN
local ES_FG_YELLOW
local ES_FG_BLUE
local ES_FG_MAGENTA
local ES_FG_CYAN
local ES_FG_WHITE

# Background Colors
local ES_BG_BLACK
local ES_BG_RED
local ES_BG_GREEN
local ES_BG_YELLOW
local ES_BG_BLUE
local ES_BG_MAGENTA
local ES_BG_CYAN
local ES_BG_WHITE

# Use terminfo escape sequences, if available.
if [[ -x "/usr/bin/tput" ]] && tput setaf &> /dev/null; then
  # Terminfo functions to obtain foreground/background color sequences
  escape_seq::setaf() { tput setaf "$1" 2> /dev/null; }
  escape_seq::setab() { tput setab "$1" 2> /dev/null; }

  ES_RESET="$(tput sgr0)"
  ES_BOLD="$(tput bold)"
  ES_DIM="$(tput dim)"
  ES_STANDOUT="$(tput smso)"
  ES_UNDERSCORE="$(tput smul)"
  ES_BLINK="$(tput blink)"
  ES_REVERSE="$(tput rev)"
  ES_HIDDEN="$(tput invis)"

# Otherwise, use ANSI escape sequences.
else
  # ANSI functions to obtain foreground/background color sequences
  escape_seq::setaf() { echo "\e["$((30+$1))"m"; }
  escape_seq::setab() { echo "\e["$((40+$1))"m"; }

  ES_RESET="\e[0m"
  ES_BOLD="\e[1m"
  ES_DIM="\e[2m"
  ES_STANDOUT="\e[3m"
  ES_UNDERSCORE="\e[4m"
  ES_BLINK="\e[5m"
  ES_REVERSE="\e[7m"
  ES_HIDDEN="\e[8m"
fi

ES_FG_BLACK="$(escape_seq::setaf 0)"
ES_FG_RED="$(escape_seq::setaf 1)"
ES_FG_GREEN="$(escape_seq::setaf 2)"
ES_FG_YELLOW="$(escape_seq::setaf 3)"
ES_FG_BLUE="$(escape_seq::setaf 4)"
ES_FG_MAGENTA="$(escape_seq::setaf 5)"
ES_FG_CYAN="$(escape_seq::setaf 6)"
ES_FG_WHITE="$(escape_seq::setaf 7)"

ES_BG_BLACK="$(escape_seq::setab 0)"
ES_BG_RED="$(escape_seq::setab 1)"
ES_BG_GREEN="$(escape_seq::setab 2)"
ES_BG_YELLOW="$(escape_seq::setab 3)"
ES_BG_BLUE="$(escape_seq::setab 4)"
ES_BG_MAGENTA="$(escape_seq::setab 5)"
ES_BG_CYAN="$(escape_seq::setab 6)"
ES_BG_WHITE="$(escape_seq::setab 7)"

unset escape_seq::setaf escape_seq::setab
