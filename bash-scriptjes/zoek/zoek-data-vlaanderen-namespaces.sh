#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "Zoek data.vlaanderen namespaces gebruikt in een bestand"
	echo "Argumenten:"
	echo "  bestand(en) waarin te zoeken, bijvoorbeeld doc/applicatieprofiel/*/index.html"
	exit 1
fi

while [[ $1 != '' ]] ; do
	echo "=== $1"
	grep -o 'https*://data\.vlaanderen\.be/ns/[^#]*#' $1 | sort -u
	shift
done
