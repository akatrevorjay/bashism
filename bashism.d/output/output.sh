#!/bin/bash

## {{{ Init 
$b.include colors
## }}}

## {{{ Syslog logger coproc
[[ -z "$BASHISM_OUTPUT_SYSLOG" ]] || \
    coproc logger { logger -p "local7.info" -t "${__BASHISM[script_self]}[$$]"; }
## }}}

## {{{ Normal app output
function bashism.output.output {
	# Set default color
	[[ -n "$COLOR" ]] || local COLOR="%light_gray%"

	[[ -n "$BASHISM_OUTPUT_LEVEL" ]] || \
		local BASHISM_OUTPUT_LEVEL="${FUNCNAME[1]}"

	case "$BASHISM_OUTPUT_LEVEL" in
		debug|warn|warning|error|death) ;;
		*) BASHISM_OUTPUT_LEVEL="info" ;;
	esac

	## Find what generated this output
	if [[ -z "$BASHISM_OUTPUT_FUNC" ]]; then
		local j=0 i=; for i in ${FUNCNAME[@]:1:3}; do case "$i" in
			*) j=$(($j + 1)) ;;&
			debug|e|error|info|death)			continue ;;
			#$HOOK|main|source)					break ;;
			*) local BASHISM_OUTPUT_FUNC="$i";	break ;;
		esac; done
	fi

	if [[ -z "$BASHISM_OUTPUT_SOURCE" ]]; then
		local BASHISM_OUTPUT_SOURCE="${BASH_SOURCE[$j]#$PWD/}"
		BASHISM_OUTPUT_SOURCE="${BASHISM_OUTPUT_SOURCE#./}:${BASH_LINENO[$(($j - 1))]}"
	fi

	[[ -n "$BASHISM_OUTPUT_HOOK" ]] || \
		local BASHISM_OUTPUT_HOOK="$hook"

    local date=$(printf "%(%F %I:%M%P)T" -1)
	if [[ ! -z "${__BASHISM[colors]}" ]]; then
		bashism.colors.colorize "$COLOR[$date] %blue%[$(printf "%18s" "$BASHISM_OUTPUT_SOURCE")]"\
			"%white%[$(printf "%8s" "$BASHISM_OUTPUT_HOOK")] %white%${BASHISM_OUTPUT_FUNC}: ${COLOR}$*%light_gray%"
	else
		echo "[$date] [$(printf "%18s" "$BASHISM_OUTPUT_SOURCE")] [$(printf "%8s" "$BASHISM_OUTPUT_HOOK")] ${BASHISM_OUTPUT_FUNC}: $*"
	fi

	[[ -z "$BASHISM_OUTPUT_SYSLOG" ]] || \
		echo "[$BASHISM_OUTPUT_SOURCE] [$BASHISM_OUTPUT_HOOK] ${BASHISM_OUTPUT_FUNC}: $*" >&${logger[1]}
}

function debug		{ [[ ! "${__BASHISM[debug]}" ]] || COLOR="%green%" bashism.output.output DEBUG: "$@"; }
function info		{ bashism.output.output "$@"; }
function e			{ bashism.output.output "$@"; }
function warning 	{ COLOR="%blue%" bashism.output.output "$@"; }
function warn    	{ COLOR="%blue%" bashism.output.output "$@"; }
function error		{ COLOR="%red%%bold%" bashism.output.output ERROR: "$@" >&2; }
function death		{
	COLOR="%red%%bold%" bashism.output.output DEATH: "$@" >&2
	[[ "$BASHISM_RECURSION" == "output/logger" || "$HOOK_TYPE" == "cleanup" ]] || return 1
}
## }}}

