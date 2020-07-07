# Dotfiles

This is my dotfiles project, intended for **macOS** and **Debian/Ubuntu** based distros.

## Requirements

* All scripts in the [bin](https://github.com/llovely/dotfiles/tree/master/bin) directory are executable. Ensure that Bash can be located by adding its path to the PATH enviornment variable (your system most likely already has Bash installed and present in your PATH enviornment variable). If the following command does not indicate the location of the Bash executable:
  ```bash
  $ which bash
  ```
  Locate your Bash executable, or lookup how to install Bash on your system, then ***append its path*** to your PATH enviornment variable (shown below):
  ```bash
  $ PATH=/path/to/bash:$PATH
  ```
* A minimum of Bash Version 3 is required to execute scripts in the [bin](https://github.com/llovely/dotfiles/tree/master/bin) directory, and to properly execute shell specific dotfiles (.bashrc and .bash_profile). To view your Bash version, execute:
  
  ```bash
  $ bash --version
  ```
  If Bash is older than Version 3, then lookup how to install a newer version of Bash on your system, then ***append its path*** to your PATH enviornment variable (as shown above).

## Download

This repo **MUST** be placed in your HOME directory, with the directory named '.dotfiles'
```bash
$ cd ~
$ git clone https://github.com/llovely/dotfiles.git .dotfiles
```

If you don't want to place this repo directly in your HOME directory, you could create a symbolic link to it, as follows:
```bash
$ git clone https://github.com/llovely/dotfiles.git
$ ln -sf /full/path/to/this/repo ~/.dotfiles
```


## Installation

During installation, the following steps will occur:

1. Install OS specific packages and applications
2. Change user's default shell to Bash
3. Install dotfiles (this will overwrite existing dotfiles in your HOME directory)

Run the following command to install:
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


## Executables

The following executables in the [bin](https://github.com/llovely/dotfiles/tree/master/bin) directory are executed by the [install](https://github.com/llovely/dotfiles/tree/master/bin/install) script above (though some are dependent on the system's OS).

* [brew](https://github.com/llovely/dotfiles/tree/master/bin/brew)
* [apt](https://github.com/llovely/dotfiles/tree/master/bin/apt)
* [dotfiles](https://github.com/llovely/dotfiles/tree/master/bin/dotfiles)

If you do not want to do the full installation listed above, then you may select any number of these executables. Details on each are listed below.

### [brew](https://github.com/llovely/dotfiles/tree/master/bin/brew) (macOS)

This executable will install Homebrew, followed by installing the desired Formulae and Casks (Packages and Applications) on macOS.

A list of the Formulae and Casks to be installed can be found here:
* [Formulae](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_formula)
* [Casks](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_cask)

Run the following command to install:
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

If you want to update Homebrew, or have added additional [Formulae](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_formula) and/or [Casks](https://github.com/llovely/dotfiles/tree/master/install/homebrew/brew_cask) to install, simply rerun the above command.

### [apt](https://github.com/llovely/dotfiles/tree/master/bin/apt) (Debian/Ubuntu)

This executable will install packages and repositories using the APT package manager on Debian/Ubuntu based distros.

A list of the packages and repositories to be installed can be found here:
* [Packages]()
* [Repositories](): In order to install certain packages, certain repositories must be installed and available package lists updated, first. This is typically a multi-step process; therefore, seperate functions are created to install each package.  

Run the following command to install:
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

If you want to update, upgrade, or have added additional [packages]() and/or [repositories]() to install, simply rerun the above command.

### [dotfiles](https://github.com/llovely/dotfiles/tree/master/bin/dotfiles)

This executable will install dotfiles in your HOME directory (existing dotfiles of the same name will be overwritten). The [shell](https://github.com/llovely/dotfiles/tree/master/shell) and [config](https://github.com/llovely/dotfiles/tree/master/config) directories contain all the dotfiles that will be installed.

Symbolic links are created for the following dotfiles and directories in your HOME directory:

* [.bash_profile](https://github.com/llovely/dotfiles/tree/master/shell/bash_profile)
* [.bashrc](https://github.com/llovely/dotfiles/tree/master/shell/bashrc): Depending of the system's OS, dotfiles in [shell/macOS](https://github.com/llovely/dotfiles/tree/master/shell/macOS) or [shell/debian](https://github.com/llovely/dotfiles/tree/master/shell/debian) will be sourced.
* [.inputrc](https://github.com/llovely/dotfiles/tree/master/config/inputrc)
* [.vim/](https://github.com/llovely/dotfiles/tree/master/config/vim)
* [.vimrc](https://github.com/llovely/dotfiles/tree/master/config/vim/vimrc)

The following dotfiles are copied into your HOME directory:
* [.gitconfig](https://github.com/llovely/dotfiles/tree/master/config/git/gitconfig): If you desire to make changes to this file, you must alter the original file located [here](https://github.com/llovely/dotfiles/tree/master/config/git/gitconfig).
* .private: Intended to store private commands, configurations, credentials, etc. This file is not under version control, nor will it be commited to a public repository. This file will be sourced by your [.bashrc](https://github.com/llovely/dotfiles/tree/master/shell/bashrc) file.

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

  # Dummy Alias
  alias theAnswer="echo 42"
  ```

Run the following command to install:
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

If changes were made to the original [.gitconfig](https://github.com/llovely/dotfiles/tree/master/config/git/gitconfig) file, simply rerun the above command. All other alterations to any dotfile in the [shell](https://github.com/llovely/dotfiles/tree/master/shell) or [config](https://github.com/llovely/dotfiles/tree/master/config) directories should take place upon a shell restart.

## Acknowledgements

Inspiratiion for this project was taken from the following sources:

* [@CoreyMSchafer](https://github.com/CoreyMSchafer) (Corey Schafer)
  [https://github.com/CoreyMSchafer/dotfiles](https://github.com/CoreyMSchafer/dotfiles)
* [@necolas](https://github.com/necolas) (Nicolas Gallagher)
  [https://github.com/necolas/dotfiles](https://github.com/necolas/dotfiles)
* [@webpro](https://github.com/webpro) (Lars Kappert)
  [https://github.com/webpro/dotfiles](https://github.com/webpro/dotfiles)
