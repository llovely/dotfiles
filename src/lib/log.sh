#
# log: Logging Library
#
# Library for logging output, for debugging purposes. After setting up a logging
# directory and log file, logged output can be obtained via a provided string or
# piped through stdin.
#

# Global Constants
readonly LOG_ID_REGEX='^log_([0-9]{2}-){2}[0-9]{4}_[0-9]{2}(-[0-9]{2}){2}$'
readonly LOG_INDENT_SIZE='  '
readonly LOG_DIR='logs'


# Globals (these variable(s) can be set by the user of the library)
LOG_PARENT_DIR='.'
LOG_DISPLAY_OUTPUT_WITH_TIMESTAMP='false'
LOG_DISPLAY_OUTPUT='true'
LOG_DISPLAY_ERR_MSG='true'
declare -i LOG_INDENT_LEVEL=0
declare -i LOG_INDENT_LEVEL_OFFSET=0


################################################################################
# Creates a log identifier.
# Globals:
#   FUNCNAME
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes log identifier to stdout; writes error message(s) to stderr.
# Returns:
#   0 if log identifier created; otherwise, non-zero on error.
################################################################################
function log::id_create() {
  local id

  id="log_"$(date +"%m-%d-%Y_%H-%M-%S" 2> /dev/null)""
  if (( $? != 0 )); then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to create log ID." >&2
    return 1
  fi

  echo "${id}"
}


################################################################################
# Verifies a log identifier.
# Globals:
#   LOG_ID_REGEX
# Arguments:
#   Log ID
# Outputs:
#   None
# Returns:
#   0 if log identifier is valid; otherwise, 1. Other non-zero on error.
################################################################################
function log::id_valid() {
  local id="$1"

  [[ "${id}" =~ $LOG_ID_REGEX ]] &> /dev/null
}


################################################################################
# Helper function to verify arguments of all log::dir_* functions.
# Globals:
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Function name of caller; log ID
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if valid arguments were provided; otherwise, non-zero on error.
################################################################################
function log::_dir_func_validate_args() {
  local func_name="$1"
  local id="$2"

  if [[ -z "${id}" ]]; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${func_name}() failed. Blank log ID provided." >&2
    return 1
  fi

  if ! log::id_valid "${id}"; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${func_name}() failed. Invalid log ID '${id}' provided." >&2
    return 1
  fi
}


################################################################################
# Indicates if a logging directory exists.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
# Arguments:
#   Log ID
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if logging directory exists; otherwise 1. Other non-zero on error.
################################################################################
function log::dir_exists() {
  local id="$1"
  local log_dir_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}"

  log::_dir_func_validate_args "${FUNCNAME[0]}" "${id}" || return 2

  [[ -d "${log_dir_path}" ]] &> /dev/null
}


################################################################################
# Verifies that a logging directory has the correct permissions.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if logging directory has valid permissions; otherwise, non-zero on error.
################################################################################
function log::dir_valid_permissions() {
  local id="$1"
  local log_dir_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}"

  log::_dir_func_validate_args "${FUNCNAME[0]}" "${id}" || return 1

  if ! log::dir_exists "${id}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${id}' logging directory does not" \
         "exist." >&2
    return 1
  fi

  # Make sure logging directory has execute permission (to enter directory)
  if [[ ! -x "${log_dir_path}" ]]; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to access '${id}' logging" \
         "directory; does not have execute permission set." >&2
    return 0
  fi

  # Make sure logging directory has read/write permissions
  if ! [[ -r "${log_dir_path}" && -w "${log_dir_path}" ]]; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${id}' logging directory does" \
         "not have read and/or write permissions." >&2
    return 0
  fi
}


################################################################################
# Creates a logging directory.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if logging directory was created; otherwise, non-zero on error.
################################################################################
function log::dir_create() {
  local id="$1"
  local log_dir_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}"

  log::_dir_func_validate_args "${FUNCNAME[0]}" "${id}" || return 1

  if ! log::dir_exists "${id}" &> /dev/null; then
    # Create new logging directory
    if ! mkdir -p "${log_dir_path}" &> /dev/null; then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. An error occured while creating" \
           "'${id}' logging directory." >&2
      return 1
    fi

    # Grant read/write/execute permissions to new logging directory
    if ! chmod u+rwx "${log_dir_path}" &> /dev/null; then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to grant read, write, and" \
          "execute permissions to '${id}' logging directory." >&2
      return 1
    fi
  else
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${id}' logging directory already" \
         "exists." >&2
    return 1
  fi
}


################################################################################
# Deletes a logging directory.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if logging directory was deleted; otherwise, non-zero on error.
################################################################################
function log::dir_remove() {
  local id="$1"
  local log_dir_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}"

  log::_dir_func_validate_args "${FUNCNAME[0]}" "${id}" || return 1

  if ! log::dir_exists "${id}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${id}' logging directory does not" \
         "exist." >&2
    return 1
  fi

  if ! rm -rf "${log_dir_path}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to remove '${id}' logging" \
         "directory." >&2
    return 1
  fi
}


################################################################################
# Helper function to verify arguments of all log::file_* functions.
# Globals:
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Function name of caller; log ID; log filename
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if valid arguments were provided; otherwise, non-zero on error.
################################################################################
function log::_file_func_validate_args() {
  local func_name="$1"
  local id="$2"
  local log_file="$3"

  # Useful to verify log ID
  log::_dir_func_validate_args "${func_name}" "${id}" || return 1

  if ! log::dir_exists "${id}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${func_name}() failed. '${id}' logging directory does not" \
         "exist." >&2
    return 1
  fi

  if ! log::dir_valid_permissions "${id}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${func_name}() failed. '${id}' logging directory does not" \
         "have the proper read, write, and/or execute permissions set." >&2
    return 1
  fi

  if [[ -z "${log_file}" ]]; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${func_name}() failed. Blank log filename provided." >&2
    return 1
  fi
}


################################################################################
# Indicates if a log file exists.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
# Arguments:
#   Log ID; log filename
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if log file exists; otherwise 1. Other non-zero on error.
################################################################################
function log::file_exists() {
  local id="$1"
  local log_file="$2"
  local log_file_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}/${log_file}"

  log::_file_func_validate_args "${FUNCNAME[0]}" "${id}" "${log_file}" || \
  return 2

  [[ -f "${log_file_path}" ]] &> /dev/null
}


################################################################################
# Verifies that a log file has the correct permissions.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID; log filename
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if log file has valid permissions; otherwise, non-zero on error.
################################################################################
function log::file_valid_permissions() {
  local id="$1"
  local log_file="$2"
  local log_file_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}/${log_file}"

  log::_file_func_validate_args "${FUNCNAME[0]}" "${id}" "${log_file}" || \
  return 1

  if ! log::file_exists "${id}" "${log_file}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${log_file}' log file does not" \
         "exist." >&2
    return 1
  fi

  # Make sure log file has read/write permissions
  if ! [[ -r "${log_file_path}" && -w "${log_file_path}" ]]; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${log_file}' log file does not" \
         "have valid read and/or write permissions." >&2
    return 1
  fi
}


################################################################################
# Creates a log file.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID; Log filename
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if log file created; otherwise, non-zero on error.
################################################################################
function log::file_create() {
  local id="$1"
  local log_file="$2"
  local log_file_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}/${log_file}"

  log::_file_func_validate_args "${FUNCNAME[0]}" "${id}" "${log_file}" || \
  return 1

  if ! log::file_exists "${id}" "${log_file}" &> /dev/null; then
    # Create new log file
    if ! touch "${log_file_path}" &> /dev/null; then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to create '${log_file}'" \
           "log file in '${id}' logging directory." >&2
      return 1
    fi

    # Grant read/write permissions to new log file
    if ! chmod u+rw "${log_file_path}" &> /dev/null; then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to grant read and write" \
          "permissions to '${log_file}' log file in '${id}' logging" \
          "directory." >&2
      return 1
    fi
  else
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${log_file}' log file already" \
         "exists in '${id}' logging directory." >&2
    return 1
  fi
}


################################################################################
# Deletes a log file.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID; Log filename
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if log file deleted; otherwise, non-zero on error.
################################################################################
function log::file_remove() {
  local id="$1"
  local log_file="$2"
  local log_file_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}/${log_file}"

  log::_file_func_validate_args "${FUNCNAME[0]}" "${id}" "${log_file}" || \
  return 1

  if ! log::file_exists "${id}" "${log_file}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${log_file}' log file does not" \
         "exist." >&2
    return 1
  fi

  if ! rm -rf "${log_file_path}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to remove '${log_file}' log" \
         "file from '${id}' logging directory." >&2
    return 1
  fi
}


################################################################################
# Clears the file contents of a log file.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Log ID; Log filename
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if contents of log file cleared; otherwise, non-zero on error.
################################################################################
function log::file_clear() {
  local id="$1"
  local log_file="$2"
  local log_file_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}/${log_file}"

  log::_file_func_validate_args "${FUNCNAME[0]}" "${id}" "${log_file}" || \
  return 1

  if ! log::file_exists "${id}" "${log_file}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${log_file}' log file does not" \
         "exist." >&2
    return 1
  fi

  if ! echo -n "" > "${log_file}"; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to clear the contents of" \
         "'${log_file}' log file from '${id}' logging directory." >&2
  fi
}


################################################################################
# Helper function to format and output messages to stdout and/or a log file.
# Globals:
#   LOG_DISPLAY_OUTPUT_WITH_TIMESTAMP
#   LOG_INDENT_LEVEL_OFFSET
#   LOG_INDENT_LEVEL
#   LOG_INDENT_SIZE
#   LOG_DISPLAY_OUTPUT
# Arguments:
#   Output message; Log filename
# Outputs:
#   Writes a message to stdout and/or appends a message to Log filename.
# Returns:
#   0 if message outputted to stdout and/or appended to log file; otherwise,
#   non-zero on error.
################################################################################
function log::_output_format() {
  local msg="$1"
  local file="$2"
  local indent_offset=''
  local indent_level=''

  # Obtains current timestamp
  local curr_time=""
  if [[ "${LOG_DISPLAY_OUTPUT_WITH_TIMESTAMP}" == 'true' ]]; then
    curr_time="$(date +"%m-%d-%Y (%H:%M:%S)" 2> /dev/null)"
    (( $? != 0 )) && return 1
  fi

  # Calculates total indentation level
  local i=0
  for (( i = $LOG_INDENT_LEVEL_OFFSET; i > 0; i-- )); do
    indent_offset+="${LOG_INDENT_SIZE}"
  done
  for (( i = $LOG_INDENT_LEVEL; i > 0; i-- )); do
    indent_level+="${LOG_INDENT_SIZE}"
  done

  # Outputs formatted output message
  if [[ "${LOG_DISPLAY_OUTPUT}" == 'true' ]]; then
    echo "${msg}" || return 1
  fi
  echo "${curr_time}> ${indent_offset}${indent_level}${msg}" >> "${file}" \
  || return 1
}


################################################################################
# Helper function to output a message provided as a parameter.
# Globals:
#   None
# Arguments:
#   Output message; Log filename
# Outputs:
#   Writes message(s) to stdout; writes error message(s) to stderr.
# Returns:
#   0 if message(s) outputted to stdout and/or appended to log file; otherwise,
#   non-zero on error.
################################################################################
function log::_output_parameter() {
  local msg="$1"
  local file="$2"
  declare -i ret_code

  # Reads lines from stdin
  while IFS= read -r line &> /dev/null; ret_code="$?"; (( $ret_code == 0 )); do
    log::_output_format "${line}" "${file}" || return 1
  done <<< "${msg}"

  if (( $ret_code != 1 )); then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Encountered a read error while" \
         "processing output." >&2
    return 1
  fi
  return 0
}


################################################################################
# Helper function to output a message piped in from stdin.
# Globals:
#   None
# Arguments:
#   Log filename
# Outputs:
#   Writes message(s) to stdout; writes error message(s) to stderr.
# Returns:
#   0 if message(s) outputted to stdout and/or appended to log file; otherwise,
#   non-zero on error.
################################################################################
function log::_output_piped() {
  local file="$1"
  declare -i ret_code

  # Reads lines from stdin
  while IFS= read -r line &> /dev/null; ret_code="$?"; (( $ret_code == 0 )); do
    log::_output_format "${line}" "${file}" || return 1
  done < /dev/stdin

  if (( $ret_code != 1 )); then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Encountered a read error while" \
         "processing output." >&2
    return 1
  fi
  return 0
}


################################################################################
# Outputs message(s) to stdout and/or a log file.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Piped Input Boolean; Log ID; Log filename; Message (optional)
# Outputs:
#   Writes message(s) to stdout/; writes error message(s) to stderr.
# Returns:
#   0 if message(s) outputted to stdout and/or appended to log file; otherwise,
#   non-zero on error.
################################################################################
function log::output() {
  local is_piped="$1"
  local id="$2"
  local log_file="$3"
  local log_file_path="${LOG_PARENT_DIR}/${LOG_DIR}/${id}/${log_file}"
  local msg="$4"

  log::_file_func_validate_args "${FUNCNAME[0]}" "${id}" "${log_file}" || \
  return 1

  if ! log::file_exists "${id}" "${log_file}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${id}' log file does not exist." >&2
    return 1
  fi

  if ! log::file_valid_permissions "${id}" "${log_file}" &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. '${id}' log file does not have" \
         "valid read and/or write permissions." >&2
    return 1
  fi

  local -i exit_status
  if [[ "${is_piped}" == 'true' ]]; then
    log::_output_piped "${log_file_path}"
    exit_status="$?"
  else
    log::_output_parameter "${msg}" "${log_file_path}"
    exit_status="$?"
  fi

  if (( $exit_status != 0 )); then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Logging of output terminated" \
         "prematurely." >&2
    return 1
  fi
}


################################################################################
# Performs full setup of creating a logging directory and log file.
# Globals:
#   FUNCNAME
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   Overwrite Log directory Boolean; Overwrite Log file Boolean; Log filename;
#   Log ID (optional)
# Outputs:
#   Writes Log ID to stdout; writes error message(s) to stderr.
# Returns:
#   0 if setup completed successfully; otherwise, non-zero on error.
################################################################################
function log::setup() {
  local force_overwrite_dir="$1"
  local force_overwrite_file="$2"
  local log_file="$3"
  local id="$4"

  # Obtain log ID
  if [[ -z "${id}" ]]; then
    id="$(log::id_create)"
    if (( $? != 0 )); then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
      return 1
    fi
  fi

  # Validate log ID
  if ! log::id_valid "${id}"; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
    return 1
  fi

  # Create logging directory
  if ! log::dir_exists "${id}"; then
    if ! log::dir_create "${id}"; then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
      return 1
    fi
  else
    if [[ "${force_overwrite_dir}" == 'true' ]]; then
      log::dir_remove "${id}" && log::dir_create "${id}"
      if (( $? != 0 )); then
        [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
        echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
        return 1
      fi
    else
      if ! log::dir_valid_permissions "${id}"; then
        [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
        echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
        return 1
      fi
    fi
  fi

  # Create log file
  if ! log::file_exists "${id}" "${log_file}"; then
    if ! log::file_create "${id}" "${log_file}"; then
      [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
      return 1
    fi
  else
    if [[ "${force_overwrite_file}" == 'true' ]]; then
      log::file_remove "${id}" "${log_file}" \
        && log::file_create "${id}" "${log_file}"
      if (( $? != 0 )); then
        [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
        echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
        return 1
      fi
    else
      if ! log::file_valid_permissions "${id}" "${log_file}"; then
        [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
        echo "ERROR: ${FUNCNAME[0]}() failed. See above for details." >&2
        return 1
      fi
    fi
  fi

  # Output log ID for use elsewhere
  echo "${id}"
}


################################################################################
# Deletes all logs from the logging directory.
# Globals:
#   FUNCNAME
#   LOG_PARENT_DIR
#   LOG_DIR
#   LOG_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if all logs were deleted; otherwise, non-zero on error.
################################################################################
function log::clear_all_logs() {
  if ! rm -rf "${LOG_PARENT_DIR}/${LOG_DIR}/"* &> /dev/null; then
    [[ "${LOG_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to clear all logs." >&2
    return 1
  fi
}
