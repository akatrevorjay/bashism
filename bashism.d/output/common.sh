#!/bin/bash

## {{{ TODO Prefix output functions

_prefixout () {
	getfd "$1"; shift
	local fd="${ret[0]}"

	#echo "fd=$fd args=$*"
    "$@" >&${fd}
	echo >&${fd}-
}

prefixout () {
    prefix="$1"; shift
    eval _prefixout >(sed -e 's/^/test/g') "$@" 
}

## }}}

## {{{ -> getfd($fd) -- Leaves $ret[0] with the fd number of $1
getfd() {
	unset ret; ret=()
	ret[0]="${1#/dev/fd/}"
}
## }}}


## {{{ Nullify out functions
## --- Don't show std(out|err) for "$@"
function nullout		{ "$@" >/dev/null; }
function nullouterr		{ "$@" >&/dev/null; }
function prefixout		{ "${@:2}" |& stdbuf -oL sed -e "s/^/$1/"; }
## }}}

## {{{ Padding functions

## Left padding
function bashism.output.lpad {	local cmd="$1"; shift; printf "%${1}s" "$*"; }

## Right padding with custom str
function bashiam.output.rpad_with {
	for word in "${@:3}"; do
		while [ ${#word} -lt $1 ]; do word="$word$2"; done
		while [ ${#word} -gt $1 ]; do word=${word:0:$((${#word}-1))}; done
		echo "$word"
	done
}

## Left padding with custom str
function bashism.output.lpad_with {
	for word in "${@:3}"; do
		while [ ${#word} -lt $1 ]; do word="$2$word"; done
		while [ ${#word} -gt $1 ]; do word=${word:1:$((${#word}-1))}; done
		echo "$word"
	done
}

## Center padding with custom str
function bashism.output.cpad_with {
	for word in "${@:3}"; do
		while [ ${#word} -lt $1 ]; do
			word="$word$2";
			if [ ${#word} -lt $1 ]; then
				word="$2$word"
			fi;
		done;
		while [ ${#word} -gt $1 ]; do
			word=${word:0:$((${#word}-1))}
			if [ ${#word} -gt $1 ]; then
				word=${word:1:$((${#word}-1))}
			fi;
		done
		echo "$word"
	done
}

## }}}

