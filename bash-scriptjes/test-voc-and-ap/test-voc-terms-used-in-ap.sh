#!/bin/bash

if [ "$#" -lt 2 ]; then
	echo "Zoek in een AP specificatie uri's die niet voorkomen in een VOC specificatie."
	echo "Toe te passen op de index.html van een AP en de index.html van een VOC."
	echo ""
	echo "Let op: vindt ook enkele URLs die geen URIs zijn die in het vocabularium kunnen gedefinieerd zijn; filter ze manueel"
	echo ""
	echo "Argumenten:"
	echo "  arg1"
	echo "    de bestandnaam van de index.html van een AP (in een clone van OSLO-Generated)"
	echo "  arg2"
	echo "    de bestandnaam van de index.html van een VOC (in een clone van OSLO-Generated)"
	exit 1
fi

AP=$1
VOC=$2

# Check één URI
# $1: URI
function chk() {
	local URI=$1
	local URI1=${URI//./\.}
	if ! grep -E -q ">$URI1<" $VOC ; then
		echo "Not found: $URI"
	fi
}

# 1. find the URIs referenced in the AP
# 2. sort them unique
# 3. check whether the URI appears in the VOC
grep -E -o '<a href="(http|https):\/\/[^"]+"' $AP | grep -o '".*"' | tr -d '"' | sort --unique | while read u ; do chk $u ; done
