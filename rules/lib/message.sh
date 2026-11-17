#!/bin/sh
# Print the commit message without comments or the verbose-commit diff.
sed '/^# -\{24\} >8 -\{24\}$/,$d' "$1" | grep -v '^#'
