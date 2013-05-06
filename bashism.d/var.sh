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


## -> b.template(@what, key1=val1, key2=val2)
## Takes $what, and replaces %key1% with val1 and etc
function bashism.var.template() {
    eval "$($b.getkwargs "$@")"
    local ret="${args[0]}"

    local k= v=
    for k in "${!kwargs[@]}"; do
        v="${kwargs[$k]}"
        ret="${ret//%$k%/$v}"
    done

    declare -p ret
}


bashism.cmd_path.push bashism.var
