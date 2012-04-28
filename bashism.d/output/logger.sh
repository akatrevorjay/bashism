#!/bin/bash -e

## {{{ Spawned coproc

if [[ -z "${__BASHISM[path]}" ]]; then
	#[[ "$BASHISM_RECURSION" == "output/logger" ]] || (echo "Cannot run output/logger without recursion" >&2; exit 1)
	export BASHISM_MINIMAL=0

	# Load bashism
	. "${0%/*}/../../bashism"

	# Get initial settings
	read name
	__BASHISM[script_self]="$name"

	# Load standard output
	$b.include output/output

	# Logger loop
	pr_nl=0; level=info
	while read log; do
		if [[ "$log" == "" ]]; then
			let pr_nl+=1
			continue
		fi

		if [[ "${log:0:16}" == '^BASHISM:logger$' ]]; then
			
			for i in ${log:17}; do
				k="${i%%=*}"; v="${i#*=}"

				case "$k" in
					level)	BASHISM_OUTPUT_LEVEL="$v"	;;
					func)	BASHISM_OUTPUT_FUNC="$v"	;;
					source)	BASHISM_OUTPUT_SOURCE="$v"	;;
					hook)	BASHISM_OUTPUT_HOOK="$v"	;;
					'##')	break		;;
					#*)		continue	;;
				esac
			done

			if [[ $pr_nl > 0 ]]; then
				pr_nl=$(($pr_nl - 1))
			fi
			log="${log#*## }"
		fi
		
		if [[ $pr_nl > 0 ]]; then
			for i in `seq 1 $pr_nl`; do echo; done
			pr_nl=0
		fi
		
		case "$BASHISM_OUTPUT_LEVEL" in
			debug|warning|error|death) "$BASHISM_OUTPUT_LEVEL" "$log" ;;
			*) e "$log" ;;
		esac
	done

	$b.exit 0
fi

## }}}

## {{{ Bashism include

## Recursive checks
[[ "$BASHISM_RECURSION" == "output/logger" ]] && \
	(echo "It looks like I am being run within a logger instance but the logger instance didn't run." >&2;
	 echo "Something is wrong. Aborting to avoid booty loops." >&2; exit 1)
export BASHISM_RECURSION="output/logger"

#coproc logger { "${__BASHISM[path]}/bashism.d/logger.sh"; }
#exec 1>${logger[1]} 2>&1

## Tell the logger coproc what to log as
echo "${__BASHISM[script_self]}"

## }}}

## {{{ Normal app output
function bashism.output.logger.send {

	local level="${FUNCNAME[1]}"
	case "$level" in
		debug|warning|error|death) ;;
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
function error		{ bashism.output.logger.send "$@"; }
function death  	{
	bashism.output.logger.send "$@"
	[[ "$HOOK_TYPE" == "cleanup" ]] || exit 1
}

## }}}


