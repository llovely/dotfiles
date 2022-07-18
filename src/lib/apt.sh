#
# apt: APT Library
#
# Library to manage packages from the APT package manager.
#

# Global Constants
readonly APT_BUNDLE_FILE='Aptfile'


# Globals (these variable(s) can be set by the user of the library)
APT_BUNDLE_DIR='.'
APT_DISPLAY_ERR_MSG='true'


################################################################################
# Determines if the APT package manager and associated utilities are installed.
# Globals:
#   FUNCNAME
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if APT and utilities are installed; otherwise, non-zero on error.
################################################################################
function apt::installed() {
  declare -a pkgs=( 'apt' 'apt-get' 'apt-cache' 'apt-mark' )

  local pkg
  for pkg in "${pkgs[@]}"; do
    if ! which "${pkg}" &> /dev/null; then
      [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
        && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to locate" \
                "'${pkg}'." >&2
      return 1
    fi
  done
}


################################################################################
# Updates package lists.
# Globals:
#   FUNCNAME
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes packge update information to stdout; writes error message(s) to
#   stderr.
# Returns:
#   0 if the package lists were updated; otherwise, non-zero on error.
################################################################################
function apt::update() {
  if ! sudo apt-get update; then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Failed to update package" \
              "lists." >&2
    return 1
  fi
}


################################################################################
# Upgrades installed packages.
# Globals:
#   FUNCNAME
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes package upgrade information to stdout; writes error message(s) to
#   stderr.
# Returns:
#   0 if the packages were upgraded; otherwise, non-zero on error.
################################################################################
function apt::upgrade() {
  if ! sudo apt-get upgrade --yes; then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Failed to upgrade all" \
              "packages." >&2
    return 1
  fi
}


################################################################################
# Determines if an APT package is installed.
# Globals:
#   FUNCNAME
#   PIPESTATUS
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT package (string)
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if package is installed; otherwise 1. Other non-zero on error.
################################################################################
function apt::installed_package() {
  local package="$1"
  declare -a exit_codes

  apt list --installed 2> /dev/null | grep -s -m 1 "^${package}/" &> /dev/null
  exit_codes=( "${PIPESTATUS[@]}" )

  if (( exit_codes[0] != 0 || exit_codes[1] > 1 )); then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. An error occured while" \
              "determining if '${package}' is installed." >&2
    return 2
  fi

  return "${exit_codes[1]}"
}


################################################################################
# Installs provided APT package.
# Globals:
#   FUNCNAME
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT package (string)
# Outputs:
#   Writes install statements to stdout; writes error message(s) to stderr.
# Returns:
#   0 if package is installed; otherwise, non-zero on error.
################################################################################
function apt::install_package() {
  local package="$1"

  if ! sudo apt-get install "${package}" --yes; then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Failed to install '${package}'" \
              "package." >&2
    return 1
  fi
}


################################################################################
# Determines if an APT package can be upgraded.
# Globals:
#   FUNCNAME
#   PIPESTATUS
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT package (string)
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if package is upgradeable; otherwise 1. Other non-zero on error.
################################################################################
function apt::upgradeable_package() {
  local package="$1"
  declare -a exit_codes

  apt list --upgradeable 2> /dev/null | grep -s -m 1 "^${package}/" &> /dev/null
  exit_codes=( "${PIPESTATUS[@]}" )

  if (( exit_codes[0] != 0 || exit_codes[1] > 1 )); then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. An error occured while" \
              "determining if '${package}' is upgradeable." >&2
    return 2
  fi

  return "${exit_codes[1]}"
}


################################################################################
# Upgrades provided APT package.
# Globals:
#   FUNCNAME
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT package (string)
# Outputs:
#   Writes upgrade statements to stdout; writes error message(s) to stderr.
# Returns:
#   0 if package is upgraded; otherwise, non-zero on error.
################################################################################
function apt::upgrade_package() {
  local package="$1"

  if ! sudo apt-get install --only-upgrade "${package}" --yes; then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Failed to upgrade '${package}'" \
              "package." >&2
    return 1
  fi
}


################################################################################
# Bundles all MANUALLY installed APT packages into a single file.
# Globals:
#   FUNCNAME
#   APT_BUNDLE_DIR
#   APT_BUNDLE_FILE
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT bundle file filepath (optional)
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if APT bundle file successfully created; otherwise, non-zero on error.
################################################################################
function apt::bundle() {
  local file="$1"

  # Use default APT bundle file, if no file provided
  if [[ -z "${1+x}" ]]; then
    file="${APT_BUNDLE_DIR}/${APT_BUNDLE_FILE}" 
  fi

  apt-mark showmanual > "${file}" 2> /dev/null
  if (( $? != 0 )); then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to bundle manually" \
              "installed packages." >&2
    return 1
  fi
}


################################################################################
# Determines if an APT bundle file exists.
# Globals:
#   FUNCNAME
#   APT_BUNDLE_DIR
#   APT_BUNDLE_FILE
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT bundle file filepath (optional)
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if APT bundle file exists; otherwise, non-zero on error.
################################################################################
function apt::bundle_exists() {
  local file="$1"

  # Use default APT bundle file, if no file provided
  if [[ -z "${1+x}" ]]; then
    file="${APT_BUNDLE_DIR}/${APT_BUNDLE_FILE}" 
  fi

  if [[ ! -e "${file}" ]]; then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. '${file}' file does not" \
              "exist." >&2
    return 1
  fi

  if ! [[ -f "${file}" && -r "${file}" ]]; then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to read '${file}'" \
              "file." >&2
    return 1
  fi
}


################################################################################
# Installs APT packages from a bundle file.
#
# NOTE: The behavior of this function mimics that from the Homebrew (macOS
#       package manager) command:
#
#       brew bundle install
#
# Globals:
#   FUNCNAME
#   APT_BUNDLE_DIR
#   APT_BUNDLE_FILE
#   APT_DISPLAY_ERR_MSG
# Arguments:
#   APT bundle file filepath (optional)
# Outputs:
#   Writes installation steps to stdout; writes error message(s) to stderr.
# Returns:
#   0 if all APT packages successfully installed; otherwise, non-zero on error.
################################################################################
function apt::install_bundle() {
  declare -i num_pkgs=0
  declare -i num_pkgs_failed=0
  local file="$1"

  # Use default APT bundle file, if no file provided
  if [[ -z "${1+x}" ]]; then
    file="${APT_BUNDLE_DIR}/${APT_BUNDLE_FILE}" 
  fi

  # Verify that Aptfile exists
  apt::bundle_exists > /dev/null || return 1

  # Update package lists (to upgrade any package already installed from Aptfile)
  echo "Running 'apt-get update'..."
  apt::update > /dev/null || return 1

  # Install packages
  echo -e "\nInstalling packages..."
  local pkg
  local exit_code
  while read -r pkg; exit_code="$?"; (( exit_code == 0 )); do
    # Determine if package is already installed
    if apt::installed_package "${pkg}" &> /dev/null; then
      # Upgrades package, if available
      if apt::upgradeable_package "${pkg}" &> /dev/null; then
        echo "Upgrading ${pkg}"
        if ! sudo apt-get update --only-upgrade "${pkg}" --yes > /dev/null; then
          [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
            && echo "Upgrading '${pkg}' has failed!" >&2
          (( num_pkgs_failed += 1 ))
        fi
      # Package is already up-to-date
      else
        echo "Using ${pkg}"
      fi
    # Installs package
    else
      echo "Installing ${pkg}"
      if ! sudo apt-get install "${pkg}" --yes > /dev/null; then
        [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
          && echo "Installing '${pkg}' has failed!" >&2
        (( num_pkgs_failed += 1 ))
      fi
    fi
    (( num_pkgs += 1 ))
  done < "${file}"

  # Verifies that the entire bundle file was read successfully
  if (( exit_code > 1 )); then
    [[ "${APT_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. An error occured while" \
              "processing bundle file." >&2
    return 1
  fi
  echo -e "\nSuccessfully installed $(( $num_pkgs - $num_pkgs_failed )) of" \
          "${num_pkgs} packages."

  # Indicates if all packages were installed successfully
  (( num_pkgs_failed == 0 ))
}
