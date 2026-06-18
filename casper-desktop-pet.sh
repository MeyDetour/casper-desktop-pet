#!/bin/sh
printf '\033c\033]0;%s\a' casper-desktop-pet
base_path="$(dirname "$(realpath "$0")")"
"$base_path/casper-desktop-pet.x86_64" "$@"
