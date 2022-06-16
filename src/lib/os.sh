#
# os: Operating System Library
#
# Library to identify and provide basic information on the system's operating
# system (OS). Supported OS's include macOS and Debian/Ubuntu based distros.
# A supported OS implies that the functions in this library should succeed in
# providing OS information; success with non-supported OS's is not guaranteed.
#

# Global Constants
readonly OS_NAME_MACOS='macOS'
readonly OS_NAME_UBUNTU='ubuntu'
readonly OS_NAME_DEBIAN='debian'
readonly OS_FIELD_UNKNOWN='<field_unknown>'
declare -ra OS_SUPPORTED_OS=(   # Array of "supported" OS's
  "${OS_NAME_MACOS}"
  "${OS_NAME_UBUNTU}"
  "${OS_NAME_DEBIAN}"
)


# Globals (these variable(s) can be set by the user of the library)
OS_DISPLAY_ERR_MSG='true'


################################################################################
# Helper function to obtain basic OS information.
# Globals:
#   OSTYPE
#   OS_NAME_MACOS
#   OS_FIELD_UNKNOWN
# Arguments:
#   None
# Outputs:
#   Writes OS information in an underscore-separated-value format to stdout.
#   Fields include (in order):
#     - NAME
#     - ID
#     - ID_LIKE
#     - PRETTY_NAME
#     - VERSION_ID
#     - VERSION_CODENAME
# Returns:
#   0 if OS information obtained; otherwise, non-zero on error.
################################################################################
function os::_info() {
  local result
  case "${OSTYPE}" in
    darwin*)
      result="$(
        which -s sw_vers || exit 1
        NAME="${OS_NAME_MACOS}"
        ID="$(sw_vers -productName 2> /dev/null)"
        (( $? != 0 )) || [[ -z "${ID}" ]] && exit 1
        ID_LIKE='darwin'
        VERSION_ID="$(sw_vers -productVersion 2> /dev/null)"
        (( $? != 0 )) || [[ -z "${VERSION_ID}" ]] && exit 1
        PRETTY_NAME="${ID} ${VERSION_ID}"
        VERSION_CODENAME="ask-apple-marketing-dept" # Cannot reliably obtain
        printf "%s_%s_%s_%s_%s_%s\n" "${NAME}" "${ID}" "${ID_LIKE}" \
          "${PRETTY_NAME}" "${VERSION_ID}" "${VERSION_CODENAME}"
      )"
      (( $? != 0 )) && return 1
      ;;
    linux*)
      result="$(
        INFO_FILE='/etc/os-release'
        [[ -f "${INFO_FILE}" && -r "${INFO_FILE}" ]] || exit 1
        source "${INFO_FILE}"
        # ID_LIKE, VERSION_ID, and VERSION_CODENAME are optional fields.
        [[ -z "${NAME}"                                         \
          || -z "${ID}"                                         \
          || -z "${ID_LIKE:-"${OS_FIELD_UNKNOWN}"}"             \
          || -z "${PRETTY_NAME}"                                \
          || -z "${VERSION_ID:-"${OS_FIELD_UNKNOWN}"}"          \
          || -z "${VERSION_CODENAME:-"${OS_FIELD_UNKNOWN}"}" ]] \
          && exit 1
        printf "%s_%s_%s_%s_%s_%s\n" "${NAME}" "${ID}" "${ID_LIKE}" \
          "${PRETTY_NAME}" "${VERSION_ID}" "${VERSION_CODENAME}"
      )"
      (( $? != 0 )) && return 1
      ;;
    *) # Unknown OS
      return 1
      ;;
  esac

  echo "${result}"
}


################################################################################
# Obtains basic OS information.
# Globals:
#   FUNCNAME
#   OS_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr; writes OS information fields to stdout.
#   Fields include (in order):
#     - NAME
#     - ID
#     - ID_LIKE
#     - PRETTY_NAME
#     - VERSION_ID
#     - VERSION_CODENAME
# Returns:
#   0 if OS information obtained; otherwise, non-zero on error.
################################################################################
function os::info() {
  local NAME
  local ID
  local ID_LIKE
  local PRETTY_NAME
  local VERSION_ID
  local VERSION_CODENAME

  local output
  output="$(os::_info 2> /dev/null)"
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to obtain system's OS" \
         "information." >&2
    return 1
  fi

  IFS='_' read NAME ID ID_LIKE PRETTY_NAME VERSION_ID VERSION_CODENAME \
  <<< "${output}" &> /dev/null
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to parse system's OS" \
         "information." >&2
    return 1
  fi

  echo "NAME:             ${NAME}"
  echo "ID:               ${ID}"
  echo "ID_LIKE:          ${ID_LIKE}"
  echo "PRETTY_NAME:      ${PRETTY_NAME}"
  echo "VERSION_ID:       ${VERSION_ID}"
  echo "VERSION_CODENAME: ${VERSION_CODENAME}"
}


################################################################################
# Determines if the system's OS is among the list of supported OS's.
# Globals:
#   FUNCNAME
#   OS_SUPPORTED_OS
#   OS_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if OS information obtained; otherwise, 1. Other non-zero on error.
################################################################################
function os::supported() {
  local NAME
  local ID
  local ID_LIKE
  local REST  # Remainder of unparsed OS info

  local output
  output="$(os::_info 2> /dev/null)"
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to determine system's OS." >&2
    return 2
  fi

  IFS='_' read NAME ID ID_LIKE REST <<< "${output}" &> /dev/null
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to parse system's OS" \
         "information." >&2
    return 2
  fi

  local os
  for os in "${OS_SUPPORTED_OS[@]}"; do
    [[ "${os}" == "${ID}" || "${os}" == "${ID_LIKE}" ]] && return 0
  done

  return 1
}


################################################################################
# Indicates the system's OS name.
# Globals:
#   FUNCNAME
#   OS_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes the system's OS to stdout; writes error message(s) to stderr.
# Returns:
#   0 if the system's OS name was determined; otherwise, non-zero on error.
################################################################################
function os::name() {
  local NAME
  local ID
  local ID_LIKE
  local PRETTY_NAME
  local REST  # Remainder of unparsed OS info

  local output
  output="$(os::_info 2> /dev/null)"
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to determine system's OS." >&2
    return 1
  fi

  IFS='_' read NAME ID ID_LIKE PRETTY_NAME REST <<< "${output}" &> /dev/null
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to parse system's OS" \
         "information." >&2
    return 1
  fi

  echo "${PRETTY_NAME}"
}


################################################################################
# Indicates the lineage/type of the system's OS.
# Globals:
#   FUNCNAME
#   OS_SUPPORTED_OS
#   OS_FIELD_UNKNOWN
#   OS_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes the system's OS lineage/type to stdout; writes error message(s) to
#   stderr.
# Returns:
#   0 if the system's OS name was determined; otherwise, non-zero on error.
################################################################################
function os::type() {
  local NAME
  local ID
  local ID_LIKE
  local REST  # Remainder of unparsed OS info

  local output
  output="$(os::_info 2> /dev/null)"
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to determine system's OS." >&2
    return 1
  fi

  IFS='_' read NAME ID ID_LIKE REST <<< "${output}" &> /dev/null
  if (( $? != 0 )); then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to parse system's OS" \
         "information." >&2
    return 1
  fi

  local os
  for os in "${OS_SUPPORTED_OS[@]}"; do
    if [[ "${os}" == "${ID}" || "${os}" == "${ID_LIKE}" ]]; then
      echo "${os}"
      return 0
    fi
  done

  if [[ "${ID_LIKE}" == "${OS_FIELD_UNKNOWN}" ]]; then
    [[ "${OS_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to determine system's OS" \
         "lineage/type." >&2
    return 1
  fi

  echo "${ID_LIKE}"
}
