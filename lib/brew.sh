#
# dotfiles/lib/brew.sh
#
# Contains various functions for aiding in the installation and processing
# of Homebrew formula and casks.
#
# Author: Luis Love
#

isBrewInstalled() {
	return $(which -s brew)
}


installBrew() {
	if ! isBrewInstalled; then
		echo "TODO"
	else
		echo "BREW is already installed!"
	fi

	return 0
}


isBrewFormulaInstalled() {
	if brew list | grep --quiet "^$1\$"; then
		return 0
	fi

	return 1
}


installBrewFormula() {
	if ! isBrewFormulaInstalled "$1"; then 
		brew install "$1" 2> /dev/null 1>&2
		return $?
	fi
	
	return 2
}


isBrewCaskInstalled() {
	if brew cask list | grep --quiet "^$1\$"; then
		return 0
	fi

	return 1
}


installBrewCask() {
	if ! isBrewCaskInstalled "$1"; then 
		brew cask install "$1" > /dev/null 1>&2
		return $?
	fi

	return 2
}
