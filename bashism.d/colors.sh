#!/bin/bash

function bashism.colors.colorize() {
	local msg="$@"

	##TODO Why doesn't this come through from global?
	##HACK Make this work for now..
	declare -A __BASHISM_COLORS=( \
			[blue]="\033[0;34m" \
			[red]="\033[0;31m" \
			[light_red]="\033[1;31m" \
			[white]="\033[1;37m" \
			[light_gray]="\033[0;37m" \
			[green]="\033[0;32m" \
			[bold]="\033[1m" \
			[gray]="\033[0;37m"
			[pink]='\\033[38;5;211m' \
			[orange]='\\033[38;5;203m' \
			[skyblue]='\\033[38;5;111m' \
			[mediumgrey]='\\033[38;5;246m' \
			[lavender]='\\033[38;5;183m' \
			[tan]='\\033[38;5;179m' \
			[forest]='\\033[38;5;22m' \
			[maroon]='\\033[38;5;52m' \
			[hotpink]='\\033[38;5;198m' \
			[mintgreen]='\\033[38;5;121m' \
			[lightorange]='\\033[38;5;215m' \
			[lightred]='\\033[38;5;203m' \
			[jade]='\\033[38;5;35m' \
			[lime]='\\033[38;5;154m' \
			[pink_bg]='\\033[48;5;211m' \
			[orange_bg]='\\033[48;5;203m' \
			[skyblue_bg]='\\033[48;5;111m' \
			[mediumgrey_bg]='\\033[48;5;246m' \
			[lavender_bg]='\\033[48;5;183m' \
			[tan_bg]='\\033[48;5;179m' \
			[forest_bg]='\\033[48;5;22m' \
			[maroon_bg]='\\033[48;5;52m' \
			[hotpink_bg]='\\033[48;5;198m' \
			[mintgreen_bg]='\\033[48;5;121m' \
			[lightorange_bg]='\\033[48;5;215m' \
			[lightred_bg]='\\033[48;5;203m' \
			[jade_bg]='\\033[48;5;35m' \
			[lime_bg]='\\033[48;5;154m' \
			[underline]='\\033[4m' \
		)
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

