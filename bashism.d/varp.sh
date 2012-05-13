#!/bin/bash
## VARP -- Var(p)iables with Persistence

## -> b.pset(@key=val)
## Set bashism varpiables, key=val form
function bashism.var.pset() {
	local i=; for i in "$@"; do
 	    local k="${i%%=*}" v="${i#*=}"

        builtin echo "$v" > "${__BASHISM[VARP_DIR]}/$k"
		__BASHISM_VARP["$k"]="$v"
	done
}

## -> b.pget(@key)
## Gets bashism varpiables
function bashism.var.pget() {
	local i=; for i in "$@"; do
        # This is not exactly meant to be used with user data, so it's not shell safe
        if [[ -f "${__BASHISM[VARP_DIR]}/$i" ]]; then
            __BASHISM_VARP["$i"]=$(< "${__BASHISM[VARP_DIR]}/$i")
        else
            unset __BASHISM_VARP["$i"]
        fi

        builtin echo "${__BASHISM_VARP[$i]}"
	done
}

__BASHISM[VARP_DIR]="${__BASHISM[path]}/var/varp"
[[ -d "${__BASHISM[VARP_DIR]}" ]] || \
    (warn "VARP_DIR=\"$varp_dir\" does not exist, creating it."; mkdir -p "${__BASHISM[VARP_DIR]}")

