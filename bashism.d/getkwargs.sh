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
        if [[ "$v" =~ $kw_re ]]; then
            kwargs[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
        ## For people with Bash from 1999
        #if [[ "$v" = *=* ]]; then
        #    local k="${v#*=}" v="${v%%=*}"
        #    kwargs[$k]="$v"
        else
            args[${#args[@]}]="$v"
        fi
    done

    ## Bash will munge the newlines during expansion if it's being expanded,
    ## so we need to make sure that there are no newlines, with a seperator.
    #echo "$(declare -p args); $(declare -p kwargs)"
    local ret=
    ret+="$(declare -p args)"
    ret+=";"
    ret+="$(declare -p kwargs)"
    echo "$ret"
}


function bashism.getkwargs.test.getkwargs() {
    if [[ -n "$*" ]]; then
        e "--- Testing with \"$@\":"
        # Declare automatically makes variables local if you're in a function,
        # so don't be worried about your global scope getting mucked here ;)
        eval "$(bashism.getkwargs.getkwargs "$@")"
        declare -p args kwargs
        return
    fi

    # TODO Make this actually verify that the output == input, ie a test ;)
    bashism.getkwargs.test.getkwargs omg=yes=yes2 arg0 arg1 munch=faces=whatsits
    bashism.getkwargs.test.getkwargs "omg=yes=yes2 arg0" "arg1 munch=faces=whatsits"
    bashism.getkwargs.test.getkwargs "omg=yes=yes2 arg0" "arg1 munch=faces=whatsits"
    bashism.getkwargs.test.getkwargs "omg=yes=yes2 arg0" "arg1 munch=faces=whatsits"
}


bashism.cmd_path.push bashism.getkwargs
