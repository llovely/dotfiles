#
# Functions for managing output message(s) to stdout and stderr.
#

# Globals (these variable(s) can be set by the user of these utility functions)
DISPLAY_OUTPUT_MSG='true'
DISPLAY_ERROR_MSG='true'


################################################################################
# Writes message(s) to stderr.
# Globals:
#   DISPLAY_ERROR_MSG
# Arguments:
#   Message to display (string)
# Outputs:
#   Writes message(s) to stderr.
# Returns:
#   0 if message(s) display successfully; otherwise, non-zero on error.
################################################################################
function err_msg() {
  local messages="$*"

  [[ "${DISPLAY_ERROR_MSG}" == 'true' ]] && printf "${messages}\n" >&2
}


################################################################################
# Writes message(s) to stdout.
# Globals:
#   DISPLAY_OUTPUT_MSG
# Arguments:
#   Message to display (string)
# Outputs:
#   Writes message(s) to stdout.
# Returns:
#   0 if message(s) display successfully; otherwise, non-zero on error.
################################################################################
function out_msg() {
  local messages="$*"

  [[ "${DISPLAY_OUTPUT_MSG}" == 'true' ]] && printf "${messages}\n"
}
