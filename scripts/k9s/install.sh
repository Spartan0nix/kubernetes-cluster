#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

/usr/bin/test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
/usr/bin/test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
/usr/bin/test -r ~/.bash_profile && echo eval" ($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval $($(brew --prefix)/bin/brew shellenv)" >>~/.profile

brew install derailed/k9s/k9s