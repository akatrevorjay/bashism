#!/bin/bash

$b.include colors

## {{{ Syslog logger coproc

coproc logger { logger -p "local7.info" -t "${__BASHISM[script_self]}[$$]"; }
#coproc logger_formatter {}

#coproc logger { sed -re "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" -e 's/%pad%\s+//g' -e 's/%\w{3,10}%//g'| logger -p "local7.info" -t "bashism"; }
#coproc logger { sed -e "s@^@[`date`] @" >> "${__BASHISM[logger.file]}"; }

## }}}

## {{{ Normal app output
function e {
	# Set default color
	[[ -n "$COLOR" ]] || local COLOR="%light_gray%"

	## Find what generated this output
	local j=0 i=; for i in ${FUNCNAME[@]:1:3}; do case "$i" in
		*) j=$(($j + 1)) ;;&
		debug|e|error|info|death)			continue ;;
		#$HOOK|main|source)					break ;;
		*) local funcname="${i}: ";	break ;;
	esac; done

	local this_source="${BASH_SOURCE[$j]#$PWD/}"
	this_source="${this_source#./}:${BASH_LINENO[$(($j - 1))]}"

	if [[ ! -z "${__BASHISM[colors]}" ]]; then
		bashism.colors.colorize "$COLOR[`date`] %blue%[$(printf "%18s" "$this_source")]"\
			"%white%[$(printf "%8s" "$hook")] %white%$funcname${COLOR}$*%light_gray%"
	else
		echo "[`date`] [$(printf "%18s" "$this_source")] [$(printf "%8s" "$hook")] $funcname$*"
	fi

	echo "[$this_source] [$hook] $funcname$*" >&${logger[1]}
}

function debug	{ [[ ! "${__BASHISM[debug]}" ]] || COLOR="%green%" e DEBUG: "$@"; }
function info	{ e "$@"; }
function error	{ COLOR="%red%%bold%" e ERROR: "$@" >&2; }

function death  {
	COLOR="%red%%bold%" e DEATH: "$@" >&2
	[[ "$HOOK_TYPE" == "cleanup" ]] || exit 1
}
## }}}

