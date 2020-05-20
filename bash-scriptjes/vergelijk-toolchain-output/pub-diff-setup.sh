#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Voorbereiding uit te voeren alvorens andere pub-diff... scripts uit te voeren. Maakt de noodzakelijke git clones."
	echo "Argumenten:"
	echo "  arg1: naam van de referentie branch     (in OSLO-Generated.git)"
	echo "..      tevens naam van subdirectory die zal worden aangemaakt onder de huidige directory (bvb. production)"
	echo "  arg2: naam van de te vergelijken branch (in OSLO-Generated.git)"
	echo "        tevens naam van subdirectory die zal worden aangemaakt onder de huidige directory (bvb. test)"
	echo "Voer uit in een directory die nog geen dergelijke subdirectories bevat."
	exit 1
fi

REF=$1
CMP=$2

set -e
#set -x

git clone https://github.com/Informatievlaanderen/OSLO-Generated.git --branch $REF $REF
git clone https://github.com/Informatievlaanderen/OSLO-Generated.git --branch $CMP $CMP
