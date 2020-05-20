#!/bin/bash

if [ "$#" -lt 2 ]; then
	echo "Zoek uri's met Klasse disambiguatie in een vocabularium (https://data.vlaanderen.be/ns/<namespace>#<Klasse>.<attribuut>)."
	echo "Toe te passen op de index.html van een vocabularium."
	echo "In de output moet je nu zelf zoeken naar attributen die slechts één keer voorkomen."
	echo "Dat kan je best doen door de output in Excel te kopiëren en dan de tekst te splitsen in twee kolommen."
	echo "Je kan de kandidaten eventueel een kleurtje geven en ze dan aanpassen in de .eap file..."
	echo "Argumenten:"
	echo "  arg1"
	echo "    de namespace in https://data.vlaanderen.be/ns"
	echo "    bvb.: 'generiek', 'mobiliteit/trips-en-aanbod'"
	echo "  arg2"
	echo "    naam van het vocabularium HTML bestand, allicht in een locale clone van OSLO-Generated"
	echo "    bvb: 'test/doc/vocabularium/mobiliteit-trips-en-aanbod/erkendestandaard/2020-04-23/index.html'"
	exit 1
fi

NS=$1
FILE=$2

# 1. grep alle URI's die voldoen aan het formaat (ze zitten tussen > en < en bevatten één . na de #)
# 2. gooi de baseURI en de rommel er af
# 3. vervang . door spatie
# 4. behoud slechts één kopie per geval
# 5. sorteer op attribuut
grep -E -o ">https://data\.vlaanderen\.be/ns/${NS}#[^.<]+\.[^.<]+<" $FILE | grep -o '#.*' | tr -d '#<' | tr '.' ' ' | sort --unique | sort -k 2
