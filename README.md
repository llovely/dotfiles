# Dotfiles

This is my dotfiles project, intended for **macOS** and **Debian/Ubuntu** based distros.


## Requirements:

* All scripts in the [bin](https://github.com/llovely/dotfiles/tree/master/bin) directory are executable. Ensure that Bash can be located by adding its path to the PATH enviornment variable (your system most likely already has Bash installed and present in your PATH enviornment variable). If the following command does not indicate the location of the Bash executable:
  ```bash
  $ which bash
  ```
  locate your Bash executable, or lookup how to install Bash on your system, then ***append its path*** to your PATH enviornment variable (shown below):
  ```bash
  $ PATH=/path/to/bash:$PATH
  ```
* A minimum of Bash version 3 is required to execute scripts in the [bin](https://github.com/llovely/dotfiles/tree/master/bin) directory, and to properly execute shell specific dotfiles in the [shell](https://github.com/llovely/dotfiles/tree/master/shell) and [config](https://github.com/llovely/dotfiles/tree/master/config) directories. This requirement exists because the default version of Bash that ships with macOS is version 3. You ***most likely*** already have a newer version of Bash installed on your system. To view your Bash version, execute:
  
  ```bash
  $ bash --version
  ```
  If Bash is older than version 3, then lookup how to install a newer version of Bash on your system, then ***append its path*** to your PATH enviornment variable (as shown above).


## Download:

This repository **MUST** be placed in your HOME directory, with the directory named '*.dotfiles*'. To download, execute:
```bash
$ cd ~
$ git clone https://github.com/llovely/dotfiles.git .dotfiles
```

If you don't want to place this repository in your HOME directory, you could create a symbolic link to it, as follows:
```bash
$ git clone https://github.com/llovely/dotfiles.git
$ ln -sf /full/path/to/this/repo ~/.dotfiles
```
Full path names are used for creating/referencing files/directories throughout this project, which presumes everything can be found relative to '*$HOME/.dotfiles'*.


## Installation:

During installation, the following operations will occur:
1. Install OS specific packages and applications
2. Change your default shell to Bash
3. Install dotfiles (this will overwrite existing dotfiles in your HOME directory)


### Package Overview

Packages are installed using various package managers (depending on your system's OS). The package managers and corresponding packages are listed below:

* [Homebrew](https://brew.sh/) (macOS)
  * [Formulae](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_formulae)
  * [Casks](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_casks)
* [APT](https://wiki.debian.org/Apt) (Debian/Ubuntu)
  * [Packages](https://github.com/llovely/dotfiles/tree/master/install/apt/apt_packages)
  * [Package Repositories](https://github.com/llovely/dotfiles/tree/master/install/apt/apt_package_repos)
* [Snap](https://snapcraft.io/) (Debian/Ubuntu)
  * [Packages](https://github.com/llovely/dotfiles/tree/master/install/snap/snap_packages)

### How to Install

Execute the command below to install:
```bash
$ cd ~/.dotfiles/bin
$ ./install
```
Options:
<table>
    <tr>
        <td><code>-h</code></td>
        <td>Help Message</td>
    </tr>
    <tr>
        <td><code>-s</code></td>
        <td>Silent Mode</td>
    </tr>
    <tr>
        <td><code>-b &ltpath_to_bash&gt</code></td>
        <td>Path to Bash Executable </td>
    </tr>
</table>

The following executables in the [bin](https://github.com/llovely/dotfiles/tree/master/bin) directory are executed by the [install](https://github.com/llovely/dotfiles/tree/master/bin/install) script above (though some are dependent on the system's OS):

* [dotfiles](https://github.com/llovely/dotfiles/tree/master/bin/dotfiles)
* [bashShell](https://github.com/llovely/dotfiles/tree/master/bin/bashShell)
* [brew](https://github.com/llovely/dotfiles/tree/master/bin/brew) (macOS)
* [apt](https://github.com/llovely/dotfiles/tree/master/bin/apt) (Debian/Ubuntu)
* [snap](https://github.com/llovely/dotfiles/tree/master/bin/snap) (Debian/Ubuntu)

If you do not want to perform a full installation, you could execute any of the above executables individually. More details on the above executables can be found below.


### [dotfiles](https://github.com/llovely/dotfiles/tree/master/bin/dotfiles)

This executable will install dotfiles in your HOME directory (existing dotfiles of the same name will be overwritten). The [shell](https://github.com/llovely/dotfiles/tree/master/shell) and [config](https://github.com/llovely/dotfiles/tree/master/config) directories contain all the dotfiles that will be installed.

Symbolic links are created for the following dotfiles and directories in your HOME directory:

* [.bash_profile](https://github.com/llovely/dotfiles/tree/master/shell/bash_profile)
* [.bashrc](https://github.com/llovely/dotfiles/tree/master/shell/bashrc): Depending on the system's OS, dotfiles in [shell/macOS](https://github.com/llovely/dotfiles/tree/master/shell/macOS) or [shell/debian](https://github.com/llovely/dotfiles/tree/master/shell/debian) will be sourced.
* [.inputrc](https://github.com/llovely/dotfiles/tree/master/config/inputrc)
* [.vim/](https://github.com/llovely/dotfiles/tree/master/config/vim)
* [.vimrc](https://github.com/llovely/dotfiles/tree/master/config/vim/vimrc)

The following dotfiles are copied into your HOME directory:
* [.gitconfig](https://github.com/llovely/dotfiles/tree/master/config/git/gitconfig)
* .bashrc.local: Intended to store private commands, configurations, credentials, etc. This file is not under version control, nor will it be commited to a public repository. This file will be sourced by the [bashrc](https://github.com/llovely/dotfiles/tree/master/shell/bashrc) file.

  Example file:
  ```bash
  # Git credentials
  GIT_AUTHOR_NAME="Luis Love"
  GIT_AUTHOR_EMAIL="luis@example.com"
  GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
  GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

  # Set the credentials (modifies ~/.gitconfig)
  git config --global user.name "$GIT_AUTHOR_NAME"
  git config --global user.email "$GIT_AUTHOR_EMAIL"

  # Dummy Aliases
  alias theAnswer="echo '42'"
  alias theReason="echo 'Who knows, who cares...'"
  ```

Execute the below command to install dotfiles:
```bash
$ cd ~/.dotfiles/bin
$ ./dotfiles
```
Options:
<table>
    <tr>
        <td><code>-h</code></td>
        <td>Help Message</td>
    </tr>
    <tr>
        <td><code>-s</code></td>
        <td>Silent Mode</td>
    </tr>
    <tr>
        <td><code>-l &ltlog_ID&gt</code></td>
        <td>Log Directory Identifier</td>
    </tr>
</table>

If changes were made to the original [gitconfig](https://github.com/llovely/dotfiles/tree/master/config/git/gitconfig) file, simply rerun the above command and restart your shell for the changes to take effect. All other alterations to any dotfile in the [shell](https://github.com/llovely/dotfiles/tree/master/shell) or [config](https://github.com/llovely/dotfiles/tree/master/config) directories should take place upon a shell restart.


### [bashShell](https://github.com/llovely/dotfiles/tree/master/bin/bashShell)

This executable changes your default shell to Bash (only if the located Bash executable is version 3 or higher).

Execute the command below to change your default shell to Bash:
```bash
$ cd ~/.dotfiles/bin
$ ./bashShell
```
Options:
<table>
    <tr>
        <td><code>-h</code></td>
        <td>Help Message</td>
    </tr>
    <tr>
        <td><code>-s</code></td>
        <td>Silent Mode</td>
    </tr>
    <tr>
        <td><code>-l &ltlog_ID&gt</code></td>
        <td>Log Directory Identifier</td>
    </tr>
    <tr>
        <td><code>-b &ltpath_to_bash&gt</code></td>
        <td>Path to Bash Executable </td>
    </tr> 
</table>


### [brew](https://github.com/llovely/dotfiles/tree/master/bin/brew) (macOS)

This executable will install the [Homebrew](https://brew.sh/) package manager, followed by installing the desired formulae and casks (packages and applications) on macOS.

A list of the formulae and casks to be installed can be found here:
* Homebrew [Formulae](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_formula)
* Homebrew [Casks](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_cask)

Execute the command below to install Homebrew + formulae and casks:
```bash
$ cd ~/.dotfiles/bin
$ ./brew
```
Options:
<table>
    <tr>
        <td><code>-h</code></td>
        <td>Help Message</td>
    </tr>
    <tr>
        <td><code>-s</code></td>
        <td>Silent Mode</td>
    </tr>
    <tr>
        <td><code>-l &ltlog_ID&gt</code></td>
        <td>Log Directory Identifier</td>
    </tr>
</table>

If you want to update Homebrew, upgrade existing formulae or casks, or have added additional [formulae](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_formula) and/or [casks](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_cask) to install, simply rerun the above command.

### [apt](https://github.com/llovely/dotfiles/tree/master/bin/apt) (Debian/Ubuntu)

This executable will install packages and repositories using the [APT](https://wiki.debian.org/Apt) package manager on Debian/Ubuntu based distros.

A list of the packages and repositories to be installed can be found here:
* APT [Packages](https://github.com/llovely/dotfiles/tree/master/install/apt/apt_packages)
* APT [Package Repositories](https://github.com/llovely/dotfiles/tree/master/install/apt/apt_package_repos): In order to install certain packages, certain repositories must be installed and available package lists updated, first. Thus, seperate functions are created to install each of these package.  

Execute the command below to install APT packages and repositories:
```bash
$ cd ~/.dotfiles/bin
$ ./apt
```
Options:
<table>
    <tr>
        <td><code>-h</code></td>
        <td>Help Message</td>
    </tr>
    <tr>
        <td><code>-s</code></td>
        <td>Silent Mode</td>
    </tr>
    <tr>
        <td><code>-l &ltlog_ID&gt</code></td>
        <td>Log Directory Identifier</td>
    </tr>
</table>

If you want to update, upgrade, or have added additional [packages](https://github.com/llovely/dotfiles/tree/master/install/apt/apt_packages) and/or [repositories](https://github.com/llovely/dotfiles/tree/master/install/apt/apt_package_repos) to install, simply rerun the above command.

### [snap](https://github.com/llovely/dotfiles/tree/master/bin/snap) (Debian/Ubuntu)

This executable will install packages using the [Snap](https://snapcraft.io/) package manager on Debian/Ubuntu based distros.

A list of the packages and repositories to be installed can be found here:
* Snap [Packages](https://github.com/llovely/dotfiles/tree/master/install/snap/snap_packages)

Execute the below command to install Snap packages:
```bash
$ cd ~/.dotfiles/bin
$ ./snap
```
Options:
<table>
    <tr>
        <td><code>-h</code></td>
        <td>Help Message</td>
    </tr>
    <tr>
        <td><code>-s</code></td>
        <td>Silent Mode</td>
    </tr>
    <tr>
        <td><code>-l &ltlog_ID&gt</code></td>
        <td>Log Directory Identifier</td>
    </tr>
</table>

If you want to update, upgrade, or have added additional [packages](https://github.com/llovely/dotfiles/tree/master/install/snap/snap_packages) to install, simply rerun the above command.


## Acknowledgements:

Inspiration for this project was taken from the following sources:

* [@CoreyMSchafer](https://github.com/CoreyMSchafer) (Corey Schafer)
  [https://github.com/CoreyMSchafer/dotfiles](https://github.com/CoreyMSchafer/dotfiles)
* [@necolas](https://github.com/necolas) (Nicolas Gallagher)
  [https://github.com/necolas/dotfiles](https://github.com/necolas/dotfiles)
* [@webpro](https://github.com/webpro) (Lars Kappert)
  [https://github.com/webpro/dotfiles](https://github.com/webpro/dotfiles)
