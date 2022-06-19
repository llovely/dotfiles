#
# mrac: Maintain Root Authentication Credentials Library
#
# Library to obtain and maintain root authentication credentials during the
# execution of a script. This library IS NOT thread-safe as the modification
# of authentication credentials through the use of the sudo command may
# propogate up to a parent process or down to all child processes.
#
# Due to thread safety, it is recommended that you DO NOT use the following
# functions, unless you know what you are doing:
#
#   - mrac::stop
#   - mrac::halt_maintain_and_stop
#
# Sourcing multiple scripts that use this library into a single script will
# lead to unexpected behavior; DO NOT DO THIS.
#

# Global Constants
declare -ri MRAC_PID_UNUSED=-1
declare -ri MRAC_RENEW_DUR_SEC_DEFAULT=60


# Globals (these variable(s) SHOULD NOT be modified outside this library)
declare -i MRAC_PID="${MRAC_PID_UNUSED}"


# Globals (these variable(s) can be set by the user of the library)
declare -i MRAC_RENEW_DUR_SEC="${MRAC_RENEW_DUR_SEC_DEFAULT}"
MRAC_DISPLAY_ERR_MSG='true'


################################################################################
# Renews root authentication credentials.
# Globals:
#   FUNCNAME
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials were renewed; otherwise, non-zero on
#   error.
################################################################################
function mrac::renew() {
  if ! sudo -nv &> /dev/null; then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Root authentication credentials" \
         "were not obtained or have expired." >&2
    return 1
  fi
}


################################################################################
# Obtains root authentication credentials.
# Globals:
#   FUNCNAME
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes password prompt(s) to stdout; writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials were provided; otherwise, non-zero
#   on error.
################################################################################
function mrac::start() {
  sudo -p "%p, please enter your password to continue: " true &> /dev/null
  if (( $? != 0 )); then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to obtain root" \
         "authentication credentials." >&2
    return 1
  fi
}


################################################################################
# Maintains root authentication credentials for the duration of a script's
# execution.
# Globals:
#   FUNCNAME
#   MRAC_PID
#   MRAC_PID_UNUSED
#   MRAC_RENEW_DUR_SEC
#   MRAC_RENEW_DUR_SEC_DEFAULT
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials are being maintained; otherwise,
#   non-zero on error.
################################################################################
function mrac::maintain() {
  # Verify that the user's credentials have not expired
  if ! mrac::renew &> /dev/null; then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Root authentication credentials" \
         "were not obtained or have expired." >&2
    return 1
  fi


  # Maintains root authentication credentials in a background command
  if (( $MRAC_PID == $MRAC_PID_UNUSED )); then
    # TODO: Background command COULD be terminated unexpectedly; parent process
    #       would not know if this happened.
    while true; do
      sudo -nv
      (( $MRAC_RENEW_DUR_SEC > 0 )) \
        && sleep "${MRAC_RENEW_DUR_SEC}" \
        || sleep "${MRAC_RENEW_DUR_SEC_DEFAULT}"
      # Terminates background command when parent process is terminated
      kill -0 "$$" || exit 0
    done &> /dev/null &
    MRAC_PID="$!"

    # Ensures that background command hasn't terminated prematurely
    if ! kill -0 "${MRAC_PID}" &> /dev/null; then
      [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to guarantee maintained" \
           "root authentication credentials for the duration of" \
           "execution." >&2
      return 1
    fi
  fi
}


################################################################################
# Obtains and maintains root authentication credentials for the duration of a
# script's execution.
# Globals:
#   FUNCNAME
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes password prompt(s) to stdout; writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials were provided and are being maintained;
#   otherwise, non-zero on error.
################################################################################
function mrac::start_and_maintain() {
  if ! { mrac::start &> /dev/null && mrac::maintain &> /dev/null; }; then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to obtain and/or maintain" \
         "root authentication credentials." >&2
    return 1
  fi
}


################################################################################
# Revokes root authentication credentials.
# Globals:
#   FUNCNAME
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials were successfully revoked; otherwise,
#   non-zero on error.
################################################################################
function mrac::stop() {
  if ! sudo -K &> /dev/null; then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to revoke root" \
         "authentication credentials." >&2
    return 1
  fi
}


################################################################################
# Stops maintaining root authentication credentials for the duration of a
# script's execution.
# Globals:
#   FUNCNAME
#   MRAC_PID
#   MRAC_PID_UNUSED
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials are no longer being maintained;
#   otherwise, non-zero on error.
################################################################################
function mrac::halt_maintain() {
  if (( $MRAC_PID == $MRAC_PID_UNUSED )); then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Root authentication" \
         "credentials are not currently being maintained." >&2
    return 1
  fi

  if ! kill "${MRAC_PID}" &> /dev/null; then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to prevent root" \
         "authentication credentials from being maintained." >&2
    return 1
  fi

  MRAC_PID="${MRAC_PID_UNUSED}"
}


################################################################################
# Stops maintaining and revokes root authentication credentials for the
# duration of a script's execution.
# Globals:
#   FUNCNAME
#   MRAC_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials are no longer being maintained and have
#   been revoked; otherwise, non-zero on error.
################################################################################
function mrac::halt_maintain_and_stop() {
  if ! { mrac::halt_maintain &> /dev/null && mrac::stop &> /dev/null; }; then
    [[ "${MRAC_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to stop maintaining and/or" \
         "revoke root authentication credentials." >&2
    return 1
  fi
}


################################################################################
# Indicates if root authentication credentials are currently being maintained
# for the duration of a script's execution.
# Globals:
#   MRAC_PID
#   MRAC_PID_UNUSED
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if root authentication credentials are currently being maintained;
#   otherwise 1. Other non-zero on error.
################################################################################
function mrac::maintain_active() {
  (( $MRAC_PID != $MRAC_PID_UNUSED )) &> /dev/null
}
