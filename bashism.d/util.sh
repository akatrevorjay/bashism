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
function bashism.util.is_function() { declare -F "$1" >/dev/null 2>&1; }
## }}}

## {{{ -> getfd($fd) -- Leaves $ret[0] with the fd number of $1
function bashism.util.getfd() { ret=("${1#/dev/fd/}"); }
## }}}

bashism.cmd_path.push 'bashism.util'

