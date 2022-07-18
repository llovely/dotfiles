#
# snap: Snap Library
#
# Library to manage packages from the Snap package manager.
#

# Global Constants
readonly SNAP_BUNDLE_FILE='Snapfile'


# Globals (these variable(s) can be set by the user of the library)
SNAP_BUNDLE_DIR='.'
SNAP_DISPLAY_ERR_MSG='true'


################################################################################
# Determines if Snap is installed.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if Snap is installed; otherwise, non-zero on error.
################################################################################
function snap::installed() {
  which snap &> /dev/null
}


################################################################################
# Installs Snap.
# Globals:
#   FUNCNAME
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes installation steps to stdout; writes error message(s) to stderr.
# Returns:
#   0 if Snap installed successfully; otherwise, non-zero on error.
################################################################################
function snap::install() {
  if ! which apt-get &> /dev/null; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. 'apt-get' is not installed;" \
              "unable to install Snap." >&2
    return 1
  fi

  if ! sudo apt-get install snapd --yes; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Failed to install Snap." >&2
    return 1
  fi
}


################################################################################
# Enables Snap services for some distros, after installation.
# Globals:
#   FUNCNAME
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes service startup steps to stdout; writes error message(s) to stderr.
# Returns:
#   0 if Snap services started successfully; otherwise, non-zero on error.
################################################################################
function snap::enable_services() {
  if ! sudo systemctl enable --now snapd apparmor; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to start Snap" \
              "services." >&2
    return 1
  fi
}


################################################################################
# Upgrades installed packages.
# Globals:
#   FUNCNAME
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   None
# Outputs:
#   Writes package upgrade information to stdout; writes error message(s) to
#   stderr.
# Returns:
#   0 if the packages were upgraded; otherwise, non-zero on error.
################################################################################
function snap::upgrade() {
  if ! sudo snap refresh; then 
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed." >&2
    return 1
  fi
}


################################################################################
# Determines if a Snap package is installed.
# Globals:
#   None
# Arguments:
#   Snap package (string)
# Outputs:
#   None
# Returns:
#   0 if package is installed; otherwise, non-zero on error.
################################################################################
function snap::installed_package() {
  local package="$1"

  snap list "${package}" &> /dev/null
}


################################################################################
# Installs provided Snap package.
# Globals:
#   FUNCNAME
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   Snap package (string).
# Outputs:
#   Writes install statements to stdout; writes error message(s) to stderr.
# Returns:
#   0 if package installed; otherwise, non-zero on error.
################################################################################
function snap::install_package() {
  local package="$1"

  if ! sudo snap install "${package}"; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to install '${package}'" \
              "package." >&2
    return 1 
  fi
}


# TODO: Wait for a snap refresh to determine what 'sudo snap refresh --list &> /snap-refresh-output' is
################################################################################
#
# Globals:
# Arguments:
# Outputs:
# Returns:
################################################################################
function snap::upgradeable_package() {
  return 1
}


################################################################################
# Upgrades provided Snap package.
# Globals:
#   FUNCNAME
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   Snap package (string)
# Outputs:
#   Writes upgrade statements to stdout; writes error message(s) to stderr.
# Returns:
#   0 if package is upgraded; otherwise, non-zero on error.
################################################################################
function snap::upgrade_package() {
  local package="$1"

  if ! sudo snap refresh "${package}"; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to install '${package}'" \
              "package." >&2
    return 1 
  fi
}


################################################################################
# Bundles all MANUALLY installed Snap packages into a single file.
#
# NOTE: All packages installed by Canonical are ignored; these packages are
#       presumed to be not manually installed.
#
# Globals:
#   FUNCNAME
#   PIPESTATUS
#   SNAP_BUNDLE_DIR
#   SNAP_BUNDLE_FILE
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   Snap bundle file filepath (optional)
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Snap bundle file successfully created; otherwise, non-zero on error.
################################################################################
function snap::bundle() {
  local file="$1"
  local exit_codes

  # Use default Snap bundle file, if no file provided
  if [[ -z "${1+x}" ]]; then
    file="${SNAP_BUNDLE_DIR}/${SNAP_BUNDLE_FILE}" 
  fi
  
  snap list \
    | grep -v Publisher \
    | grep -v canonical \
    | awk '{print $1}' > "${file}" 2> /dev/null
  exit_codes=( "${PIPESTATUS[@]}" )

  local index
  for index in { 0..3 }; do
    if (( exit_codes[index] != 0 )); then
      [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
        && echo "ERROR: ${FUNCNAME[0]}() failed. Failed to create" >&2
      return 1
    fi
  done
}


################################################################################
# Determines if a Snap bundle file exists.
# Globals:
#   FUNCNAME
#   SNAP_BUNDLE_DIR
#   SNAP_BUNDLE_FILE
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   Snap bundle file filepath (optional)
# Outputs:
#   Writes error message(s) to stderr.
# Returns:
#   0 if Snap bundle file exists; otherwise, non-zero on error.
################################################################################
function snap::bundle_exists() {
  local file="$1"

  # Use default Snap bundle file, if no file provided
  if [[ -z "${1+x}" ]]; then
    file="${SNAP_BUNDLE_DIR}/${SNAP_BUNDLE_FILE}" 
  fi

  if [[ ! -e "${file}" ]]; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. '${file}' file does not" \
              "exist." >&2
    return 1
  fi

  if ! [[ -f "${file}" && -r "${file}" ]]; then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. Unable to read '${file}'" \
              "file." >&2
    return 1
  fi
}


################################################################################
# Installs Snap packages from a bundle file.
#
# NOTE: The behavior of this function mimics that from the Homebrew (macOS
#       package manager) command:
#
#       brew bundle install
#
# Globals:
#   FUNCNAME
#   SNAP_BUNDLE_DIR
#   SNAP_BUNDLE_FILE
#   SNAP_DISPLAY_ERR_MSG
# Arguments:
#   Snap bundle file filepath (optional)
# Outputs:
#   Writes installation steps to stdout; writes error message(s) to stderr.
# Returns:
#   0 if all Snap packages successfully installed; otherwise, non-zero on error.
################################################################################
function snap::install_bundle() {
  declare -i num_pkgs=0
  declare -i num_pkgs_failed=0
  local file="$1"

  # Use default Snap bundle file, if no file provided
  if [[ -z "${1+x}" ]]; then
    file="${SNAP_BUNDLE_DIR}/${SNAP_BUNDLE_FILE}" 
  fi

  # Verify that Snapfile exists
  snap::bundle_exists "${file}" > /dev/null || return 1

  # Install packages
  echo -e "\nInstalling packages..."
  local pkg
  local exit_code
  while read -r pkg; exit_code="$?"; (( exit_code == 0 )); do
    # Determine if package is already installed
    if snap::installed_package "${pkg}" &> /dev/null; then
      # Upgrades package, if available
      if snap::upgradeable_package "${pkg}" &> /dev/null; then
        echo "Upgrading ${pkg}"
        if ! sudo snap refresh "${pkg}" > /dev/null; then
          [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
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
      if ! sudo snap install "${pkg}" > /dev/null; then
        [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
          && echo "Installing '${pkg}' has failed!" >&2
        (( num_pkgs_failed += 1 ))
      fi
    fi
    (( num_pkgs += 1 ))
  done < "${file}"

  # Verifies that the entire bundle file was read successfully
  if (( exit_code > 1 )); then
    [[ "${SNAP_DISPLAY_ERR_MSG}" == 'true' ]] \
      && echo "ERROR: ${FUNCNAME[0]}() failed. An error occured while" \
              "processing bundle file." >&2
    return 1
  fi
  echo -e "\nSuccessfully installed $(( $num_pkgs - $num_pkgs_failed )) of" \
          "${num_pkgs} packages."

  # Indicates if all packages were installed successfully
  (( num_pkgs_failed == 0 ))
}
