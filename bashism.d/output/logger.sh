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
			
			for i in ${log:0:17}; do
				k="${i%%=*}"; v="${i#*=}"

				case "$k" in
					level)	level="$v"	;;
					func)	func="$v"	;;
					source)	source="$v"	;;
					hook)	hook="$v"	;;
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
		
		case "$level" in
			debug|error|death)	"$level" "$log"	;;
			*)	e "$log" ;;
		esac
	done

	$b.exit 0
fi

## }}}

## {{{ Bashism include

## Recursive checks
#echo "$BASHISM_RECURSION"
#[[ "$BASHISM_RECURSION" != "output/logger" ]] || (echo "It looks like I am being run recursively. Something is wrong." >&2; exit 1)
export BASHISM_RECURSION="output/logger"
#coproc logger { "${__BASHISM[path]}/bashism.d/logger.sh"; }

## }}}

echo "${__BASHISM[script_self]}"

## {{{ Normal app output
function bashism.output.logger.send {

	local level="${FUNCNAME[1]}"
	case "$level" in
		debug|info|error|death) ;;
		#e)		level="info"	;;
		*)		level="info"	;;
	esac

	## Find what generated this output
	local j=0 i= func=; for i in ${FUNCNAME[@]:1:3}; do case "$i" in
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
function debug	{ bashism.output.logger.send "$@"; }
function e		{ bashism.output.logger.send "$@"; }
function info	{ bashism.output.logger.send "$@"; }
function error	{ bashism.output.logger.send "$@"; }
function death  {
	bashism.output.logger.send "$@"
	[[ "$HOOK_TYPE" == "cleanup" ]] || exit 1
}

## }}}


