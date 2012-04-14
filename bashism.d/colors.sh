#!/bin/bash

function bashism.colors.colorize() {
	local msg="$@"

	##TODO Why doesn't this come through from global?
	##HACK Make this work for now..
	declare -A __BASHISM_COLORS=([blue]="\033[0;34m" [red]="\033[0;31m" [light_red]="\033[1;31m" [white]="\033[1;37m" [light_gray]="\033[0;37m" [green]="\033[0;32m" [bold]="\033[1m" [gray]="\033[0;37m" )
	#[pad]="" )

	for i in ${!__BASHISM_COLORS[@]}; do msg="${msg//%$i%/${__BASHISM_COLORS[$i]}}"; done
	echo -e "$msg"
}

function bashism.colors.decolorize() {
	local msg="$@"
	for i in ${!__BASHISM_COLORS[@]}; do msg="${msg//%$i%/}"; done
	echo "$msg"
}

function bashism.colors.strip() {
	echo "$@" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

