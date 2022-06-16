#
# brew: Homebrew Library
#
# Library to manage the installation and packages of the Homebrew package
# manager.
#

# Constant Globals
readonly BREW_BUNDLE_FILE='Brewfile'


# Globals (these variable(s) can be set by the user of the library)
BREW_BUNDLE_DIR="."
BREW_DISPLAY_ERR_MSG='true'


################################################################################
# Determines if Homebrew is installed.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if Homebrew is installed; otherwise, non-zero on error.
################################################################################
function brew::installed() {
  which -s brew &> /dev/null
}


################################################################################
# Determines if a Homebrew formula is installed.
# Globals:
#   None
# Arguments:
#   Homebrew formula (string)
# Outputs:
#   None
# Returns:
#   0 if formula is installed; otherwise, non-zero on error.
################################################################################
function brew::installed_formula() {
  local formula="$1"

  brew list --formula "${formula}" &> /dev/null
}


################################################################################
# Determines if a Homebrew cask is installed.
# Globals:
#   None
# Arguments:
#   Homebrew cask (string)
# Outputs:
#   None
# Returns:
#   0 if cask is installed; otherwise, non-zero on error.
################################################################################
function brew::installed_cask() {
  local cask="$1"

  brew list --cask "${cask}" &> /dev/null
}


################################################################################
# Installs Homebrew.
# Globals:
#   FUNCNAME
#   BREW_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes installation steps to stdout; writes error message(s) to stderr.
# Returns:
#   0 if Homebrew installed successfully; otherwise, non-zero on error.
################################################################################
function brew::install() {
  local url

  # TODO: Look for a better non-interactive way to install this Homebrew.
  url='https://raw.githubusercontent.com/Homebrew/install/master/install.sh'
  if ! ( echo -ne '\n' | /bin/bash -c "$(curl -fsSL "${url}")" ); then
    [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. An error occured during" \
         "Homebrew installation." >&2
    return 1
  fi
}


################################################################################
# Installs Homebrew formula; reinstalls if already installed.
# Globals:
#   FUNCNAME
#   BREW_DISPLAY_ERR_MSG
# Arguments:
#   Homebrew formula (string).
# Outputs:
#   Writes error message(s) to stderr; writes install statements to stdout.
# Returns:
#   0 if formula installed; otherwise, non-zero on error.
################################################################################
function brew::install_formula() {
  local formula="$1"

  if brew::formula_installed "${formula}" &> /dev/null; then
    echo "'${formula}' formula is already installed, reinstalling."
    if ! brew reinstall --verbose --formula "${formula}"; then
      [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to reinstall" \
           "'${formula}' formula." >&2
      return 1
    fi
  else
    if ! brew install --verbose --formula "${formula}"; then
      [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to install" \
           "'${formula}' formula." >&2
      return 1
    fi
  fi
}


################################################################################
# Installs Homebrew cask; reinstalls if already installed.
# Globals:
#   FUNCNAME
#   BREW_DISPLAY_ERR_MSG
# Arguments:
#   Homebrew cask (string).
# Outputs:
#   Writes error message(s) to stderr; writes reinstall statement to stdout.
# Returns:
#   0 if cask installed; otherwise, non-zero on error.
################################################################################
function brew::install_cask() {
  local cask="$1"

  if brew::cask_installed "${cask}" &> /dev/null; then
    echo "'${cask}' cask is already installed, reinstalling."
    if ! brew reinstall --verbose --cask --require-sha "${cask}"; then
      [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to reinstall" \
           "'${cask}' cask." >&2
      return 1
    fi
  else
    if ! brew install --verbose --cask --require-sha "${cask}"; then
      [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
      echo "ERROR: ${FUNCNAME[0]}() failed. Unable to install" \
           "'${cask}' cask." >&2
      return 1
    fi
  fi
}


################################################################################
# Installs Homebrew formulae, casks, images, and taps from a bundle file.
# Globals:
#   FUNCNAME
#   BREW_BUNDLE_DIR
#   BREW_BUNDLE_FILE
#   BREW_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes installation output to stdout; writes error message(s) to stderr.
# Returns:
#   0 if casks/formulae/images/taps installed successfully; otherwise, non-zero
#   on error.
################################################################################
function brew::install_bundle() {
  brew bundle install --verbose --no-lock \
  --file="${BREW_BUNDLE_DIR/BREW_BUNDLE_FILE}"
  if (( $? != 0 )); then
    [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. An error occured while" \
         "installing all bundled casks/formulae/images/taps." >&2
    return 1
  fi
}


################################################################################
# Bundles all installed Homebrew formulae, casks, images, and taps into a single
# file.
# Globals:
#   FUNCNAME
#   BREW_BUNDLE_DIR
#   BREW_BUNDLE_FILE
#   BREW_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if casks/formulae/images/taps bundled successfully; otherwise, non-zero
#   on error.
################################################################################
function brew::bundle() {
  brew bundle dump --force --describe --quiet \
  --file="${BREW_BUNDLE_DIR/BREW_BUNDLE_FILE}" &> /dev/null
  if (( $? != 0 )); then
    [[ "${BREW_DISPLAY_ERR_MSG}" == 'true' ]] && \
    echo "ERROR: ${FUNCNAME[0]}() failed. Unable to bundle installed" \
         "casks/formulae/images/taps." >&2
    return 1
  fi
}
