#!/usr/bin/env bash
set -e

[ $(command -v git) ] || {
  echo "==> 📛📦 Missing git"
  exit 1
}
[ $(command -v curl) ] || {
  echo "==> 📛📦 Missing curl"
  exit 1
}

# Local vars
ASDF_VERSION=v0.8.1
ASDF_HOME=$HOME/.asdf
ASDF_BIN=$ASDF_HOME/asdf.sh

#
# Helper to idempotently add strings to target files
#
append_uniquely() {
  if ! grep -q "$2" "$1"; then
    echo "==> ✍ Writing \"$2\" into \"$1\" "
    echo "${2}" >>$1
  fi
}

case "${SHELL}" in
/bin/bash)
  SHELL_PROFILE=~/.bashrc
  SHELL_NAME="bash"
  ;;
/bin/zsh)
  SHELL_PROFILE=~/.zshrc
  SHELL_NAME="zsh"
  ;;
esac

echo "==> 💁 Install ASDF and plugins"

if [ ! -f "$ASDF_BIN" ]; then
  echo "===> Installing ASDF"
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_HOME" --branch $ASDF_VERSION
  [ ! command -v asdf ] &>/dev/null && {
    append_uniquely "$SHELL_PROFILE" ". $ASDF_HOME/asdf.sh"
    append_uniquely "$SHELL_PROFILE" ". $ASDF_HOME/completions/asdf.bash"
  }
fi

source "$ASDF_BIN"

if [ -d "$ASDF_HOME/plugins/nodejs" ]; then
  asdf plugin-update nodejs
else
  echo "===> Installing ASDF nodejs plugin"
  asdf plugin-add nodejs
fi

echo "===> Installing build deps with ASDF"
asdf install
# There may be problem with plugin return codes
asdf install

asdf reshim
