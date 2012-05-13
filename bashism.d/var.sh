#!/bin/bash

## -> b.set(@key=val)
## Set bashism variables, key=val form
function bashism.var.set() {
	local i=; for i in "$@"; do
		local k="${i%%=*}" v="${i#*=}"
		__BASHISM["$k"]="$v"
	done
}

## -> b.get(@key)
## Gets bashism variables
function bashism.var.get() {
	local i=; for i in "$@"; do
        unset ret; ret=("${__BASHISM["$i"]}")
	done
}

bashism.cmd_path.push bashism.var

