#
# Functions for obtaining user confirmation.
#

# Globals (these variable(s) SHOULD NOT be modified outside of this utility)
CONFIRMATION_RESPONSE=''


################################################################################
# Obtains user confirmation.
# Globals:
#   FUNCNAME
#   CONFIRMATION_RESPONSE
# Arguments:
#   Message(s) to display (string)
# Outputs:
#   Writes message(s) to stdout; writes error message(s) to stderr.
# Returns:
#   0 if confirmation obtained; otherwise, non-zero on error.
################################################################################
function seek_confirmation() {
  local messages="$*"
  local prompt="Are you sure you want to continue? [Y/n]: "

  [[ -z "${messages}" ]] || printf "${messages}\n"
  if ! read -r -p "${prompt}" CONFIRMATION_RESPONSE; then
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to obtain" \
         "confirmation." >&2
    return 1
  fi
}


################################################################################
# Indicates if confirmation is confirmed.
# Globals:
#   CONFIRMATION_RESPONSE
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if confirmation confirmed; otherwise, non-zero.
################################################################################
function is_confirmed() {
  [[ "${CONFIRMATION_RESPONSE}" =~ ^[Yy].* ]] &> /dev/null
}
