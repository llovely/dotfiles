#
# Function to determine if a Bash script is being executed with at least the
# minimum supported version of Bash.
#

# Global Constants
readonly MIN_BASH_VERSION=3  # Bash version that ships with macOS


################################################################################
# Determines if a script is being executed with at least the minimum supported
# Bash version.
# Globals:
#   BASH_VERSINFO
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if executed with at least the minimum supported Bash version; otherwise,
#   non-zero on error.
################################################################################
function valid_bash_version() {
  # TODO: This code WAS NOT tested if compliant with MIN_BASH_VERSION < 3
  if ! test $BASH_VERSINFO -ge "$MIN_BASH_VERSION"; then
    echo "ERROR: valid_bash_version() failed. This script needs to be" \
         "executed with Bash Version $MIN_BASH_VERSION or higher." 1>&2
    return 1
  fi
}
