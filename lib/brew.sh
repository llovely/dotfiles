#
# dotfiles/lib/brew.sh
#
# Contains various functions for aiding in the installation and processing
# of Homebrew formulae and casks.
#
# Author: Luis Love
#

isBrewInstalled() {
    which -s brew > /dev/null 2>&1
}


installBrew() {
    (
    echo -ne '\n' | \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    )
}


updateBrew() {
    brew update --verbose
}


isBrewFormulaInstalled() {
    (brew list | grep --quiet "^$1\$") > /dev/null 2>&1
}


installBrewFormula() {
    if isBrewFormulaInstalled "$1"; then
        brew upgrade --verbose "$1"
    else
        brew install --verbose "$1"
    fi
}


isBrewCaskInstalled() {
    (brew cask list | grep --quiet "^$1\$") > /dev/null 2>&1
}


installBrewCask() {
    if isBrewCaskInstalled "$1"; then
        brew cask upgrade --verbose "$1"
    else
        brew cask install --verbose "$1"
    fi
}
