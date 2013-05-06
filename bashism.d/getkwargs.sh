#!/bin/bash -e
# ____________
# getkwargs.sh
#
# -- Gives you simple Python-esque arguments in Bash
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

    declare -p args
    # Bash will munge the newlines during expansion, make that OK
    echo ';'
    declare -p kwargs
}


function bashism.test.getkwargs.test() {
    if [[ -n "$*" ]]; then
        echo "--- Testing with \"$@\":"
        # Declare automatically makes variables local if you're in a function,
        # so don't be worried about your global scope getting mucked here ;)
        eval $(getkwargs "$@")
        declare -p args kwargs
        echo
        return
    fi

    # TODO Make this actually verify that the output == input, ie a test ;)
    _test_getkwargs omg=yes=yes2 arg0 arg1 munch=faces=whatsits
    _test_getkwargs "omg=yes=yes2 arg0" "arg1 munch=faces=whatsits"
    _test_getkwargs "omg=yes=yes2 arg0" "arg1 munch=faces=whatsits"
    _test_getkwargs "omg=yes=yes2 arg0" "arg1 munch=faces=whatsits"
}

