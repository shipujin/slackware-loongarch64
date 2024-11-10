#!/bin/csh
# Print a fortune cookie for login shells:

# Only output a fortune if $HOME/.hushlogin does not exist,
# and this is an interactive shell:
if ( ( ! -e $HOME/.hushlogin ) && { tty --silent } ) then >& /dev/null
  echo "" ; fortune fortunes fortunes2 linuxcookie ; echo ""
endif
