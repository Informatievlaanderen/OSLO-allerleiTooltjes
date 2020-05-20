#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Vergelijking van toolchain publicatie output tussen een bestand in de referentie directory en een bestand in de te vergelijken directory."
	echo "Voer uit na zeker één pub-diff-setup.sh en bij voorkeur vanuit pub-diff-wrapper.sh."
	echo "Argumenten:"
	echo "  arg1: pad en bestandnaam van een bestand in de referentie directory"
	echo "  arg1: pad en bestandnaam van een bestand in de te vergelijken directory"
	echo "Over het vergelijken:"
	echo "  - .nt bestanden worden niet rechtstreeks vergeleken. Een voorbehandeld .nt.comparable bestand wordt vergeleken om een relevante RDF vergelijking te bekomen afgestemd op onze vocabularia. Voorbehandeling:"
	echo "    - verwijdering van regels met betrekking tot blank nodes (gaat toch enkel over de contributors)"
	echo "    - sortering"
	echo "  - andere bestanden worden rechtstreeks vergeleken"
	echo "  - alle tekstuele vergelijkingen worden gedaan met verwaarlozing van white space"
	exit 1
fi

LEFT=$1
RIGHT=$2

set -e
#set -x

DIFF_OPT="-b -B"

function convert_nt() {
	local FROM=$1
	local TO=$2
	grep -v '_:' $FROM | sort > $TO
}

echo $LEFT >&2
echo "=== $LEFT - $RIGHT"
if [[ -e $LEFT ]] ; then
	if [[ -e $RIGHT ]] ; then
		if [[ ${LEFT##*.} == nt ]] ; then
			NEWLEFT=$LEFT.comparable
			NEWRIGHT=$RIGHT.comparable
			convert_nt $LEFT $NEWLEFT
			convert_nt $RIGHT $NEWRIGHT
			diff $DIFF_OPT $NEWLEFT $NEWRIGHT || true
		elif [[ ${LEFT##*.} == jpg ]] ; then
			# binaire vergelijking
			if ! cmp -s $LEFT $RIGHT ; then
				echo "Niet gelijk"
			fi
		else
			diff $DIFF_OPT $LEFT $RIGHT || true
		fi
	else
		echo "--- Ontbreekt: $RIGHT"
	fi
else
	echo "--- Ontbreekt: $LEFT"
fi
