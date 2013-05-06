#!/bin/bash -e

## {{{ Spawned coproc

if [[ -z "${__BASHISM[path]}" ]]; then
	#[[ "$BASHISM_RECURSION" == "output/logger" ]] || (echo "Cannot run output/logger without recursion" >&2; exit 1)
	export BASHISM_MINIMAL=0

	# Load bashism
    unset BASHISM_RECURSION
	. "${BASH_SOURCE[0]%/*}/../../bashism"

	# Get initial settings
	read log
	[[ "${log:0:17}" == "^BASHISM:logger$ " || "$__BASHISM[trace]" ]] || \
		(echo "Cannot understand what is supposed to be output.logger input." >&2; exit 1)
	__BASHISM[script_self]="${log:17}"

	# Load standard output
	$b.include output/output

	# Logger loop
	pr_nl=0; level=info
	while read log; do
		if [[ -z "$log" ]]; then
			pr_nl=$(($pr_nl + 1))
			continue
		fi

		if [[ "${log:0:17}" == '^BASHISM:logger$ ' ]]; then

			for i in ${log:17}; do
				k="${i%%=*}"; v="${i#*=}"

				case "$k" in
					level)	BASHISM_OUTPUT_LEVEL="$v"	;;
					func)	BASHISM_OUTPUT_FUNC="$v"	;;
					source)	BASHISM_OUTPUT_SOURCE="$v"	;;
					hook)	BASHISM_OUTPUT_HOOK="$v"	;;
					'##')	break		;;
				esac
			done

			if [[ $pr_nl > 0 ]]; then
				pr_nl=$(($pr_nl - 1))
			fi
			log="${log#*## }"
		fi

		case "$BASHISM_OUTPUT_LEVEL" in
			e|info|debug|warn|warning|error|death) ;;
			*) BASHISM_OUTPUT_LEVEL="info" ;;
		esac

		if [[ $pr_nl > 0 ]]; then
			for i in `seq 1 $pr_nl`; do "$BASHISM_OUTPUT_LEVEL"; done
			pr_nl=0
		fi

		"$BASHISM_OUTPUT_LEVEL" "$log"
	done

	$b.exit 0
fi

## }}}

## {{{ Run this script through process substitution to simulate decent logging functionality in bash

## Recursive checks

#set -b

#BASHISM_STDOUT_ORIGINAL=3
#BASHISM_STDERR_ORIGINAL=4
exec 3>&1 4>&2
#exec 1> >("${__BASHISM[path]}/bashism.d/output/logger.sh")
getfd >( \
    BASHISM_COLORS="$BASHISM_COLORS" \
    BASHISM_DEBUG="$BASHISM_DEBUG" \
    BASHISM_QUIET="$BASHISM_QUIET" \
    "${__BASHISM[path]}/bashism.d/output/logger.sh")
BASHISM_OUTPUT_LOGGER_FD="${ret[0]}"
exec 1>&$BASHISM_OUTPUT_LOGGER_FD 2>&1
#0<"${__BASHISM[path]}/tmp0"}
#exec 2>&1

## Tell the logger coproc what to log as
echo "^BASHISM:logger$ ${__BASHISM[script_self]}"

## }}}

## {{{ bashism.output.exit
function bashism.output.exit {
    ## This helps avoid lag between the output and main processes which uglifies my tty
    ## If anyone has a better way of waiting for a command spawned via process substitution
    ## to catch up with it's buffers, let me know.
	wait
    sleep 1
}
## }}}

## {{{ Normal app output
function bashism.output.logger.send {

	local level="${FUNCNAME[1]}"
	case "$level" in
		debug|warn|warning|error|death) ;;
		*) level="info" ;;
	esac

	## Find what generated this output
	local j=1 i= func=; for i in ${FUNCNAME[@]:2:3}; do case "$i" in
		*) j=$(($j + 1)) ;;&
		#debug|e|info|error|death)			continue ;;
		#$HOOK|main|source)					break ;;
		*) func="$i";	break ;;
	esac; done

	local source="${BASH_SOURCE[$j]#$PWD/}"
	source="${source#./}:${BASH_LINENO[$(($j - 1))]}"

	echo
	echo '^BASHISM:logger$' "level=$level hook=$hook source=$source func=$func ## $*"
}

## Output functions
function debug		{ bashism.output.logger.send "$@"; }
function e			{ bashism.output.logger.send "$@"; }
function info		{ bashism.output.logger.send "$@"; }
function warning	{ bashism.output.logger.send "$@"; }
function warn       { bashism.output.logger.send "$@"; }
function error		{ bashism.output.logger.send "$@"; }
function death  	{
	bashism.output.logger.send "$@"
	[[ "$HOOK_TYPE" == "cleanup" ]] || return 1
}

## }}}


