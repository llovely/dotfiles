#
# Various escape sequences used in shell text output.
#

# Use terminfo escape sequences, if available.
if [[ -x "/usr/bin/tput" ]] && tput setaf &> /dev/null; then
  # Terminfo functions to obtain foreground/background color sequences
  function escape_seq::setaf() { tput setaf "$1" 2> /dev/null; }
  function escape_seq::setab() { tput setab "$1" 2> /dev/null; }

  # General Text Attributes
  declare -r ES_RESET="$(tput sgr0)"
  declare -r ES_BOLD="$(tput bold)"
  declare -r ES_DIM="$(tput dim)"
  declare -r ES_STANDOUT="$(tput smso)"
  declare -r ES_UNDERSCORE="$(tput smul)"
  declare -r ES_BLINK="$(tput blink)"
  declare -r ES_REVERSE="$(tput rev)"
  declare -r ES_HIDDEN="$(tput invis)"

  # Custom Foreground Colors
  declare -r ES_FG_BLACK="$(escape_seq::setaf 0)"
  declare -r ES_FG_RED="$(escape_seq::setaf 196)"
  declare -r ES_FG_GREEN="$(escape_seq::setaf 71)"
  declare -r ES_FG_YELLOW="$(escape_seq::setaf 228)"
  declare -r ES_FG_BLUE="$(escape_seq::setaf 153)"
  declare -r ES_FG_MAGENTA="$(escape_seq::setaf 90)"
  declare -r ES_FG_CYAN="$(escape_seq::setaf 37)"
  declare -r ES_FG_WHITE="$(escape_seq::setaf 15)"
  declare -r ES_FG_ORANGE="$(escape_seq::setaf 166)"

  # Custom Background Colors
  declare -r ES_BG_BLACK="$(escape_seq::setab 0)"
  declare -r ES_BG_RED="$(escape_seq::setab 196)"
  declare -r ES_BG_GREEN="$(escape_seq::setab 71)"
  declare -r ES_BG_YELLOW="$(escape_seq::setab 228)"
  declare -r ES_BG_BLUE="$(escape_seq::setab 153)"
  declare -r ES_BG_MAGENTA="$(escape_seq::setab 90)"
  declare -r ES_BG_CYAN="$(escape_seq::setab 37)"
  declare -r ES_BG_WHITE="$(escape_seq::setab 15)"
  declare -r ES_BG_ORANGE="$(escape_seq::setab 166)"

# Otherwise, use ANSI escape sequences.
else
  # ANSI functions to obtain foreground/background color sequences
  function escape_seq::setaf() { echo "\e["$((30+$1))"m"; }
  function escape_seq::setab() { echo "\e["$((40+$1))"m"; }

  # General Text Attributes
  declare -r ES_RESET="\e[0m"
  declare -r ES_BOLD="\e[1m"
  declare -r ES_DIM="\e[2m"
  declare -r ES_STANDOUT="\e[3m"
  declare -r ES_UNDERSCORE="\e[4m"
  declare -r ES_BLINK="\e[5m"
  declare -r ES_REVERSE="\e[7m"
  declare -r ES_HIDDEN="\e[8m"
fi


# Original Foreground Colors (uses original default color, if variable not set)
[[ -z "${ES_FG_BLACK+x}" ]] \
  && declare -r ES_FG_BLACK="$(escape_seq::setaf 0)"
[[ -z "${ES_FG_RED+x}" ]] \
  && declare -r ES_FG_RED="$(escape_seq::setaf 1)"
[[ -z "${ES_FG_GREEN+x}" ]] \
  && declare -r ES_FG_GREEN="$(escape_seq::setaf 2)"
[[ -z "${ES_FG_YELLOW+x}" ]] \
  && declare -r ES_FG_YELLOW="$(escape_seq::setaf 3)"
[[ -z "${ES_FG_BLUE+x}" ]] \
  && declare -r ES_FG_BLUE="$(escape_seq::setaf 4)"
[[ -z "${ES_FG_MAGENTA+x}" ]] \
  && declare -r ES_FG_MAGENTA="$(escape_seq::setaf 5)"
[[ -z "${ES_FG_CYAN+x}" ]] \
  && declare -r ES_FG_CYAN="$(escape_seq::setaf 6)"
[[ -z "${ES_FG_WHITE+x}" ]] \
  && declare -r ES_FG_WHITE="$(escape_seq::setaf 7)"
[[ -z "${ES_FG_ORANGE+x}" ]] \
  && declare -r ES_FG_ORANGE="${ES_FG_RED}" # Orange is NOT a default color


# Original Background Colors (uses original default color, if variable not set)
[[ -z "${ES_BG_BLACK+x}" ]] \
  && declare -r ES_BG_BLACK="$(escape_seq::setab 0)"
[[ -z "${ES_BG_RED+x}" ]] \
  && declare -r ES_BG_RED="$(escape_seq::setab 1)"
[[ -z "${ES_BG_GREEN+x}" ]] \
  && declare -r ES_BG_GREEN="$(escape_seq::setab 2)"
[[ -z "${ES_BG_YELLOW+x}" ]] \
  && declare -r ES_BG_YELLOW="$(escape_seq::setab 3)"
[[ -z "${ES_BG_BLUE+x}" ]] \
  && declare -r ES_BG_BLUE="$(escape_seq::setab 4)"
[[ -z "${ES_BG_MAGENTA+x}" ]] \
  && declare -r ES_BG_MAGENTA="$(escape_seq::setab 5)"
[[ -z "${ES_BG_CYAN+x}" ]] \
  && declare -r ES_BG_CYAN="$(escape_seq::setab 6)"
[[ -z "${ES_BG_WHITE+x}" ]] \
  && declare -r ES_BG_WHITE="$(escape_seq::setab 7)"
[[ -z "${ES_BG_ORANGE+x}" ]] \
  && declare -r ES_BG_ORANGE="${ES_BG_RED}" # Orange is NOT a default color


unset -f escape_seq::setaf 
unset -f escape_seq::setab
