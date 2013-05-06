#!/bin/bash -e
# ____________
# getkwargs.sh
#
# -- Gives you simple Python-esque arguments in Bash
#    ie: your_function_or_script never=always sync daemon=True
#
# TODO Enhance interface with standard opts support: -p|--path[=blah]
#
# ~trevorj 05/05/2013


function bashism.getkwargs.getkwargs() {
    local -A kwargs=()
    local -a args=()

    local kw_re='^([a-zA-Z][a-zA-Z0-9_]*)=(.+)$'

    local k= v=
    for v in "$@"; do
        ## For people with Bash from 1999, it doesn't do very strict keyword
        ## checking, however.
        #if [[ "$v" = *=* ]]; then
        #    local k="${v#*=}" v="${v%%=*}"
        #    kwargs[$k]="$v"

        if [[ "$v" =~ $kw_re ]]; then
            kwargs[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
        else
            args[${#args[@]}]="$v"
        fi
    done

    ## Bash will munge the newlines during expansion if it's being expanded,
    ## so we need to make sure that there are no newlines, with a seperator.
    local ret=
    ret+="$(declare -p args)"
    ret+=";"
    ret+="$(declare -p kwargs)"
    echo "$ret"
}


bashism.cmd_path.push bashism.getkwargs
