#!/usr/bin/env bash

set -e

# Check if greadlink is installed
if ! command -v greadlink >/dev/null 2>&1; then
  echo "greadlink is not installed. Please install coreutils to proceed."
  exit 1
fi

# Check if the `emacs` file exists in the script's directory
if [ ! -f "$(dirname "$0")/emacs" ]; then
  echo "The file './emacs' does not exist in the script's directory."
  exit 1
fi

echo "Linking ./emacs -> ~/.emacs"
BASEDIR=$(greadlink -f "$(dirname "$0")")
ln -nsf "$BASEDIR/emacs" ~/.emacs

emacs --batch \
      --eval "(require 'package)" \
      --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\"))" \
      --eval "(package-initialize)" \
      --eval "(package-refresh-contents)" \
      --eval "(package-install (quote color-theme-sanityinc-tomorrow))" \
      --eval "(package-install (quote no-littering))" \
      --eval "(package-install (quote move-text-default-bindings))"
