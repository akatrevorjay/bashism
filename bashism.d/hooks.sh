#!/bin/bash

#bashism.var.set hooks.path="${__BASHISM[path]}/hooks.d"
bashism.var.set hooks.path="$PWD/hooks.d"

## Loops through hooks
function bashism.hooks.run_one() {
	for hook in "$@"; do
		local hook_file=; for hook_file in ${__BASHISM[hooks.path]}/*; do
			[[ ! -x "$hook_file" || ! -f "$hook_file" ]] || . "$hook_file"
		done
	done
}

## Adds a hook to the pushed hook stack
function bashism.hooks.push() {
	local i=; for i in "$@"; do
		## Dont add a hook multiple times
		#[[ -z "${__BASHISM_HOOKS_PUSHED[$i]}" ]] || continue
		#__BASHISM_HOOKS_PUSHED[$i]=${#__BASHISM_HOOKS_PUSHED[@]}

		__BASHISM_HOOKS_PUSHED[${#__BASHISHM_HOOKS_PUSHED[@]}]="$i"
	done
}

## Loops through hooks, then recursively loop through pushed hooks and their pushed hooks, etc
function bashism.hooks.run() {
	local __BASHISM_HOOKS_PUSHED=()
	for run_hook in "$@"; do bashism.hooks.run_one "$run_hook"; done

	if [[ -n "${__BASHISM_HOOKS_PUSHED[@]}" ]]; then
		for run_hook in "${__BASHISM_HOOKS_PUSHED[@]}"; do
			bashism.hooks.run "$run_hook"
		done
	fi
}

