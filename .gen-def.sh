#!/bin/sh
set -e


echo() {
	printf "%s\n" "$*"
}

usage() {
	echo "usage: $0 [-r redirect.dll] <file.dll> [extrasyms...]" >&2
	exit 255
}

while getopts r: opt; do
	case "$opt" in
	r) redirect="$(basename "$OPTARG" .dll)";;
	*) usage;;
	esac
done
shift $(($OPTIND - 1))
[ $# -ge 1 ] || usage
dllfile="$1"; shift
extrasyms=
for sym; do
	extrasyms="$(printf "%s\n%s" "$sym" "$extrasyms")"
done
objdump="${OBJDUMP:-${CROSS_COMPILE}objdump}"


# here's hoping GNU/mingw objdump keeps its output format stable

get_ord_base() {
	"$objdump" -p "$1" | sed -nE -e 's/^Export Address Table -- Ordinal Base ([0-9]*)$/\1/p'
}

# output format: <offset> <name> for every symbol
get_exports() {
	"$objdump" -p "$1" | sed -n -e '/^\[Ordinal\/Name Pointer\] Table$/,/^$/{ /^\t/p; }' | tr -d '[]'
}

max() {
	for x; do printf "%d\n" "$x"; done | sort -rn | head -n 1
}


ordbase=$(get_ord_base "$dllfile")
maxoff=$(max $(get_exports "$dllfile" | awk '{print $1}'))


echo EXPORTS
# use a heredoc here instead of a regular pipe so that the while-loop doesn't run in a subshell,
# and variable changes it makes actually propagate
while read -r off sym; do
	ord=$((off + ordbase))
	if echo "$extrasyms" | grep -q "^$sym\$"; then
		echo "  $sym @$ord"
		extrasyms="$(echo "$extrasyms" | grep -v "^$sym\$")"
	elif [ -n "$redirect" ]; then
		echo "  $sym=$redirect.$sym @$ord"
	else
		echo "  $sym @$ord"
	fi
done <<EOI
$(get_exports "$dllfile")
EOI
# add any missing symbols we haven't encountered yet
for sym in $extrasyms; do
	maxoff=$((maxoff + 1))
	echo "  $sym @$((maxoff + ordbase))"
done
