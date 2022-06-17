#
# Function indicating if a script has been executed without sudo.
#

################################################################################
# Indicates if a script has been executed without sudo.
# Globals:
#   FUNCNAME
#   SUDO_USER
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if script executed without sudo; otherwise, non-zero on error.
################################################################################
function executed_without_sudo() {
  if [[ -n "${SUDO_USER}" ]]; then
    echo "ERROR: ${FUNCNAME[0]}() failed. Do not execute this script" \
         "with sudo." >&2
    return 1
  fi
}
