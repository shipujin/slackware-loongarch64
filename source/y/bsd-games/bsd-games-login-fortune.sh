#!/bin/sh
# Print a fortune cookie for login shells:

# Only output a fortune if $HOME/.hushlogin does not exist:
if [ ! -e $HOME/.hushlogin ]; then
  # Only output a fortune on interactive shells:
  case $- in
  *i* )  # We're interactive
    echo
    fortune fortunes fortunes2 linuxcookie
    echo
    ;;
  esac
fi
