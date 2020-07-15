#
# dotfiles/lib/snap.sh
#
# Contains various functions for aiding in the installation and processing
# of programs from linux distros using the SNAP package manager.
#
# Author: Luis Love
#

installSnap() {
    sudo apt-get install snapd --yes
}


updateSnap() {
    sudo apt-get upgrade snapd --yes
}


isSnapInstalled() {
    sudo dpkg -l snapd > /dev/null 2>&1
}


enableSnapServices() {
    sudo systemctl enable --now snapd apparmor
}


isSnapPackageInstalled() {
    (snap list | grep --quiet "^$1") > /dev/null 2>&1
}


installSnapPackage() {
    local package="$1"
    local options="$2"

    isSnapPackageInstalled "$package"
    if [[ "$?" -eq "0" ]]; then
        sudo snap refresh $options "$package"
    else
        sudo snap install $options "$package"
    fi
}
