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

## -> b.pget(@key|@var=key)
## Gets bashism varpiables, places result into var if in var=key form
function bashism.var.pget() {
	local i= v=; for i in "$@"; do
        # If key=val form
        v=; if [[ "$i" == *=* ]]; then
            v="${i%%=*}"; i="${i#*=}"
        fi

        if [[ -f "${__BASHISM[VARP_DIR]}/$i" ]]; then
            __BASHISM_VARP[$i]=$(< "${__BASHISM[VARP_DIR]}/$i")
        else
            unset __BASHISM_VARP[$i]
        fi

        ret=("${__BASHISM_VARP[$i]}")

        # If params were in key=val form
        if [[ -n "$v" ]]; then
            # Set var ${!key} equal to $val
            eval $v=\"${ret[0]}\"
        fi
	done
}

__BASHISM[VARP_DIR]="${__BASHISM[path]}/var/varp"
[[ -d "${__BASHISM[VARP_DIR]}" ]] || \
    (warning "VARP_DIR=\"$varp_dir\" does not exist, creating it."; mkdir -p "${__BASHISM[VARP_DIR]}")

