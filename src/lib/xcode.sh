#
# xcode: Xcode Library
#
# Library to verify proper installation of Xcode's Command Line Tools. Command
# Line Tools are also installed via the Xcode Application, but are located in
# a separate directory path.
#
# Installation of Xcode's Command Line Tools via terminal launches a GUI process
# to manage the installation. Therefore, it is recommended that one should
# install Homebrew, as it installs the command line tools automatically (they
# are required for Homebrew's installation process).
#

# Global Constants
readonly XCODE_CLT_PATH='/Library/Developer/CommandLineTools'
readonly XCODE_APP_PATH='/Applications/Xcode.app/Contents/Developer'


# Globals (these variable(s) can be set by the user of the library)
XCODE_DISPLAY_ERR_MSG='true'


################################################################################
# Helper function to obtain Xcode's active developer directory.
# Globals:
#   XCODE_DISPLAY_ERR_MSG
# Arguments:
#   Function name of caller
# Outputs:
#   Writes Xcode active developer directory to stdout; writes error message(s)
#   to stderr.
# Returns:
#   0 if Xcode's active developer directory obtained; otherwise, non-zero on
#   error.
################################################################################
function xcode::_obtain_xcode_path() {
  local func_name="$1"
  local xcode_path

  xcode_path="$(xcode-select --print-path 2> /dev/null)"
  if (( $? != 0 )); then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${func_name}() failed. Unable to get path to Xcode's active" \
         "developer directory." >&2
    return 1
  fi

  echo "${xcode_path}"
}


################################################################################
# Obtain the path to Xcode's active developer directory.
# Globals:
#   FUNCNAME
# Arguments:
#   None
# Outputs:
#   Writes Xcode active developer directory to stdout; writes error message(s)
#   to stderr.
# Returns:
#   0 if Xcode's active developer directory obtained; otherwise, non-zero on
#   error.
################################################################################
function xcode::get_path() {
  local xcode_path

  xcode_path="$(xcode::_obtain_xcode_path "${FUNCNAME[0]}")"
  (( $? != 0 )) && return 1

  echo "${xcode_path}"
}


################################################################################
# Installs Xcode's command line tools.
#
# NOTE: A GUI prompt will display to continue installation; this function is
#       non-blocking, meaning that an exit code of 0 will immediately return
#       while installation is being managed in the GUI.
#
# Globals:
#   FUNCNAME
#   XCODE_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr; a GUI prompt/interface to install.
# Returns:
#   0 if a request to install Xcode's command line tools succeeds; otherwise,
#   non-zero on error.
################################################################################
function xcode::install_clt() {
  if ! xcode-select --install > /dev/null; then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to install command line" \
         "tools." >&2
    return 1
  fi
}


################################################################################
# Deletes Xcode's command line tools (if not installed with Xcode application).
# Globals:
#   FUNCNAME
#   XCODE_CLT_PATH
#   XCODE_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Xcode's command line tools were deleted; otherwise, non-zero on error.
################################################################################
function xcode::remove_clt() {
  if ! sudo rm -rf "${XCODE_CLT_PATH}" &> /dev/null; then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to remove command line" \
         "tools." >&2
    return 1
  fi
}


################################################################################
# Determines if Xcode application and/or command line tools are installed.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if Xcode application/command line tools installed; otherwise, 1.
################################################################################
function xcode::installed() {
  # gcc should be installed if Xcode is.
  xcode::get_path &> /dev/null && gcc --version &> /dev/null
}


################################################################################
# Determines if Xcode application is installed (includes command line tools).
# Globals:
#   FUNCNAME
#   XCODE_APP_PATH
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Xcode application is installed; otherwise 1. Other non-zero on error.
################################################################################
function xcode::installed_app() {
  local xcode_path

  xcode_path="$(xcode::_obtain_xcode_path "${FUNCNAME[0]}")"
  (( $? != 0 )) && return 2

  xcode::installed || return 1
  [[ "${xcode_path}" == "${XCODE_APP_PATH}" ]] \
    || [[ -d "${XCODE_APP_PATH}" ]] &> /dev/null
}


################################################################################
# Determines if Xcode command line tools are installed.
# Globals:
#   FUNCNAME
#   XCODE_CLT_PATH
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Xcode command line tools are installed; otherwise 1. Other non-zero on
#   error.
################################################################################
function xcode::installed_clt() {
  local xcode_path

  xcode_path="$(xcode::_obtain_xcode_path "${FUNCNAME[0]}")"
  (( $? != 0 )) && return 2

  xcode::installed || return 1
  [[ "${xcode_path}" == "${XCODE_CLT_PATH}" ]] \
    || [[ -d "${XCODE_CLT_PATH}" ]]  &> /dev/null
}


################################################################################
# Resets Xcode's default command line tools path.
# Globals:
#   FUNCNAME
#   XCODE_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Xcode's command line tools path reset; otherwise, non-zero on error.
################################################################################
function xcode::reset() {
  if ! sudo xcode-select --reset &> /dev/null; then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to reset command line" \
         "tools path." >&2
    return 1
  fi
}


################################################################################
# Sets the path for Xcode's active developer directory.
# Globals:
#   FUNCNAME
#   XCODE_CLT_PATH
#   XCODE_APP_PATH
#   XCODE_DISPLAY_ERR_MSG
# Arguments:
#   Path to a Xcode developer directory
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Xcode's active developer directory path set; otherwise, non-zero on
#   error.
################################################################################
function xcode::switch() {
  local path="$1"
  declare -ra valid_paths=(
    "${XCODE_CLT_PATH}"
    "${XCODE_APP_PATH}"
  )

  local xcode_path
  for xcode_path in "${valid_paths[@]}"; do
    if [[ "${path}" == "${xcode_path}" ]]; then
      if ! sudo xcode-select --switch "${path}" &> /dev/null; then
        [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
        echo "ERROR: ${FUNCNAME[0]}() failed. Unable set '${path}'" \
             "as active developer directory path." >&2
        return 1
      fi
      return 0
    fi
  done

  [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
  echo "ERROR: ${FUNCNAME[0]}() failed. Invalid developer directory path" \
       "provided; expected one of the following paths:" >&2
  for xcode_path in "${valid_paths[@]}"; do
    echo "    - ${xcode_path}" >&2
  done
  return 1
}


################################################################################
# Accepts Xcode's license agreement, if using Xcode application as active
# developer directory.
# Globals:
#   FUNCNAME
#   XCODE_APP_PATH
#   XCODE_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Xcode license agreement accepted; otherwise, non-zero on error.
################################################################################
function xcode::accept_license() {
  local xcode_path

  # Check that Xcode application is installed
  if ! xcode::installed_app &> /dev/null; then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Xcode application is not" \
         "installed." >&2
    return 1
  fi

  # Check that Xcode application is the active developer directory, not the
  # command line tools
  xcode_path="$(xcode::_obtain_xcode_path "${FUNCNAME[0]}")"
  (( $? != 0 )) && return 1
  if [[ "${xcode_path}" != "${XCODE_APP_PATH}" ]]; then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Xcode application is not the" \
         "active developer directory." >&2
    return 1
  fi

  # Check if license agreement was accepted
  if ! sudo xcodebuild -license accept &> /dev/null; then
    [[ "${XCODE_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Failed to accept license" \
         "agreement." >&2
    return 1
  fi
}
