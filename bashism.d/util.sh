#!/bin/bash

## {{{ -> b.split($by, $str)
## If $by is empty, split by $IFS into array $ret
function bashism.util.split() {
	ret=()
	local IFS=${1:$IFS} i=; for i in ${@:2}; do
		ret[${#ret[@]}]="$i"
	done
}
## }}}

## {{{ -> b.util.is_function($name)
function bashism.util.is_function() { declare -f -F "$1" >/dev/null 2>&1; }
## }}}

bashism.cmd_path.push util

