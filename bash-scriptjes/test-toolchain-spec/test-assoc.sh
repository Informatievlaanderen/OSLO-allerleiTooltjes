#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "Test of de specificaties voor associaties correct worden gegenereerd."
	echo "Dit script is afgeleid uit 'Specificatie attributen gegenereerd voor associaties',"
	echo "  te vinden op: https://github.com/Informatievlaanderen/OSLO-handleiding/tree/master/UML2RDF/AssociatiesEnRollen."
	echo "  Het hoort er mee in sync gehouden te worden."
	echo "Argumenten:"
	echo "  arg1:"
	echo "    Directory waar de juiste branch van OSLO-Generated is uitgecheckt en up to date gebracht na elke run van de te testen publicaties."
	echo "    Voorbeeld: /c/git-workingcopies/iv/generated/test-feature-checkout"
	echo "  arg2:"
	echo "    v|q; verbose or quiet (default: q)"
	exit 1
fi

DIR=$1
MODE=${2:-q}

PREVIOUS_TITLE=
PREVIOUS_FILE=
COUNT=0

# Check één voorbeeld
# $1: titel
# $2: bestandsnaam waarin te checken
# $3: te checken tekst (voorbeeld); voor labels en definities: '>tekst<'; voor uris: 'href="tekst"'
function chk() {
	local TITLE=$1
	local FILE=$2
	local TXT=$3
	local FILE_ABS=$DIR/$FILE
	if [[ "$TITLE" != "$PREVIOUS_TITLE" ]] || [[ "$FILE" != "$PREVIOUS_FILE" ]] ; then
		PREVIOUS_TITLE=$TITLE
		PREVIOUS_FILE=$FILE
		COUNT=1
	else
		COUNT=$((COUNT + 1))
	fi
	
	local FOUND
	if FOUND=$(grep -F -o "$TXT" $FILE_ABS) ; then
		if [[ $MODE == 'v' ]] ; then
			echo "=== $TITLE, in $FILE, voorbeeld $COUNT"
			echo "--- Verwacht:"
			echo "$TXT"
			echo "--- Gevonden:"
			echo "$FOUND"
			echo "... OK"
		fi
	else
		if FOUND=$(grep -F -o -i "$TXT" $FILE_ABS) ; then
			echo "=== $TITLE, in $FILE, voorbeeld $COUNT"
			echo "--- Verwacht:"
			echo "$TXT"
			echo "--- Gevonden:"
			echo "$FOUND"
			echo "!!! Hoofdletter / kleine letter fout"
		else
			echo "=== $TITLE, in $FILE, voorbeeld $COUNT"
			echo "--- Verwacht:"
			echo "$TXT"
			echo "!!! Niet gevonden"
		fi
	fi
}

# T: titel
# F: file

T='Formule 1.1.1'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>heeft 01<'
chk "$T" "$F" '>heeft 21<'

T='Formule 1.1.2'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html 
chk "$T" "$F" '>heeft 01 AP<'
chk "$T" "$F" '>heeft 21 AP<'

T='Formule 1.1.4'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html 
chk "$T" "$F" 'href="https://extern.domein#heeft01"'
chk "$T" "$F" 'href="https://extern.domein#heeft21"'

T='Formule 1.1.5'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#heeft01"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#heeft21"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft01_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft21_naam"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#heeft01"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#heeft21"'

T='Formule 2.1.1'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>heeft 02<'
chk "$T" "$F" '>heeft 22 (source)<'
chk "$T" "$F" '>heeft 22 (target)<'

T='Formule 2.1.2'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>heeft 02 AP<'
chk "$T" "$F" '>heeft 22 AP (source)<'
chk "$T" "$F" '>heeft 22 AP (target)<'

T='Formule 2.1.4'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html 
chk "$T" "$F" 'href="https://extern.domein#heeft02"'
chk "$T" "$F" 'href="https://extern.domein#heeft22"'

T='Formule 2.1.5'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K02A.heeft02"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K02B.heeft02"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K22.heeft22.source"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K22.heeft22.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K02A_naam.Heeft02_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K02B_naam.Heeft02_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K22_naam.Heeft22_naam.source"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K22_naam.Heeft22_naam.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K02A.heeft02"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K02B.heeft02"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K22.heeft22.source"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K22.heeft22.target"'

T='Formule 3.1.1'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>k 03A rol<'
chk "$T" "$F" '>k 03A rol Tweede<'
chk "$T" "$F" '>k 03B rol<'
chk "$T" "$F" '>k 03B rol Tweede<'
chk "$T" "$F" '>k 23A rol<'
chk "$T" "$F" '>k 23A rol Tweede<'
chk "$T" "$F" '>k 23B rol<'
chk "$T" "$F" '>k 23B rol Tweede<'

T='Formule 3.1.2'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 03A rol AP<'
chk "$T" "$F" '>k 03A rol Tweede AP<'
chk "$T" "$F" '>k 03B rol AP<'
chk "$T" "$F" '>k 03B rol Tweede AP<'
chk "$T" "$F" '>k 23A rol AP<'
chk "$T" "$F" '>k 23A rol Tweede AP<'
chk "$T" "$F" '>k 23B rol AP<'
chk "$T" "$F" '>k 23B rol Tweede AP<'

T='Formule 3.1.4'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html 
chk "$T" "$F" 'href="https://extern.domein#k03Arol"'
chk "$T" "$F" 'href="https://extern.domein#k03ArolTweede"'
chk "$T" "$F" 'href="https://extern.domein#k03Brol"'
chk "$T" "$F" 'href="https://extern.domein#k03BrolTweede"'
chk "$T" "$F" 'href="https://extern.domein#k23Arol"'
chk "$T" "$F" 'href="https://extern.domein#k23ArolTweede"'
chk "$T" "$F" 'href="https://extern.domein#k23Brol"'
chk "$T" "$F" 'href="https://extern.domein#k23BrolTweede"'

T='Formule 3.1.5'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03ArolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03BrolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23ArolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23BrolTweede"'
F=doc/applicatieprofiel/documentatie/associaties-met-hoofdletters/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk03Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk03ArolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk03Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk03BrolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk23Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk23ArolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk23Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk23BrolTweede"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03ArolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k03BrolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23ArolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k23BrolTweede_naam"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk03Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk03ArolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk03Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk03BrolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk23Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk23ArolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk23Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk23BrolTweede_naam"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k03Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k03ArolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k03Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k03BrolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k23Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k23ArolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k23Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k23BrolTweede"'

T='Formule 5.1.1'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>heeft 05<'
chk "$T" "$F" '>heeft 25<'

T='Formule 5.1.2'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>heeft 05 AP<'
chk "$T" "$F" '>heeft 25 AP<'

T='Formule 5.1.4'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html 
chk "$T" "$F" 'href="https://extern.domein#heeft05"'
chk "$T" "$F" 'href="https://extern.domein#heeft25"'

T='Formule 5.1.5'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#heeft05"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#heeft25"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft05_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft25_naam"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#heeft05"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#heeft25"'

T='Formule 5.2.1.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>k 05A<'
chk "$T" "$F" '>k 25 (source)<'

T='Formule 5.2.1.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>k 05B<'
chk "$T" "$F" '>k 25 (target)<'

T='Formule 5.2.2.a'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 05A AP<'
chk "$T" "$F" '>k 25 AP (source)<'

T='Formule 5.2.2.b'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 05B AP<'
chk "$T" "$F" '>k 25 AP (target)<'

T='Formule 5.2.5.a'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html
chk "$T" "$F" 'href="https://extern.domein#Heeft05.k05A"'
chk "$T" "$F" 'href="https://extern.domein#Heeft25.k25.source"'

T='Formule 5.2.5.b'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html
chk "$T" "$F" 'href="https://extern.domein#Heeft05.k05B"'
chk "$T" "$F" 'href="https://extern.domein#Heeft25.k25.target"'

T='Formule 5.2.6.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft05.k05A"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft25.k25.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft05_naam.k05A_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft25_naam.k25_naam.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft05.k05A"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft25.k25.source"'

T='Formule 5.2.6.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft05.k05B"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft25.k25.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft05_naam.k05B_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft25_naam.k25_naam.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft05.k05B"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft25.k25.target"'

T='Formule 5.2.7.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>Referentie naar verbonden klasse.<'

T='Formule 5.2.7.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>Referentie naar verbonden klasse.<'

T='Formule 6.1.1'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>heeft 06<'
chk "$T" "$F" '>heeft 26 (source)<'
chk "$T" "$F" '>heeft 26 (target)<'

T='Formule 6.1.2'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>heeft 06 AP<'
chk "$T" "$F" '>heeft 26 AP (source)<'
chk "$T" "$F" '>heeft 26 AP (target)<'

T='Formule 6.1.4'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html 
chk "$T" "$F" 'href="https://extern.domein#heeft06"'
chk "$T" "$F" 'href="https://extern.domein#heeft26"'

T='Formule 6.1.5'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K06A.heeft06"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K06B.heeft06"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K26.heeft26.source"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K26.heeft26.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K06A_naam.Heeft06_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K06B_naam.Heeft06_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K26_naam.Heeft26_naam.source"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#K26_naam.Heeft26_naam.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K06A.heeft06"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K06B.heeft06"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K26.heeft26.source"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#K26.heeft26.target"'

T='Formule 6.2.1.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>k 06A<'
chk "$T" "$F" '>k 26 (source)<'

T='Formule 6.2.1.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>k 06B<'
chk "$T" "$F" '>k 26 (target)<'

T='Formule 6.2.2.a'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 06A AP<'
chk "$T" "$F" '>k 26 AP (source)<'

T='Formule 6.2.2.b'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 06B AP<'
chk "$T" "$F" '>k 26 AP (target)<'

T='Formule 6.2.5.a'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html
chk "$T" "$F" 'href="https://extern.domein#Heeft06.k06A"'
chk "$T" "$F" 'href="https://extern.domein#Heeft26.k26.source"'

T='Formule 6.2.5.b'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html
chk "$T" "$F" 'href="https://extern.domein#Heeft06.k06B"'
chk "$T" "$F" 'href="https://extern.domein#Heeft26.k26.target"'

T='Formule 6.2.6.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft06.k06A"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft26.k26.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft06_naam.k06A_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft26_naam.k26_naam.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft06.k06A"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft26.k26.source"'

T='Formule 6.2.6.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft06.k06B"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft26.k26.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft06_naam.k06B_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft26_naam.k26_naam.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft06.k06B"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft26.k26.target"'

T='Formule 6.2.7.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>Referentie naar verbonden klasse.<'

T='Formule 6.2.7.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>Referentie naar verbonden klasse.<'

T='Formule 7.1.1'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>k 07A rol<'
chk "$T" "$F" '>k 07B rol<'
chk "$T" "$F" '>k 07B rol Tweede<'
chk "$T" "$F" '>k 27A rol<'
chk "$T" "$F" '>k 27B rol<'
chk "$T" "$F" '>k 27B rol Tweede<'

T='Formule 7.1.2'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 07A rol AP<'
chk "$T" "$F" '>k 07B rol AP<'
chk "$T" "$F" '>k 07B rol Tweede AP<'
chk "$T" "$F" '>k 27A rol AP<'
chk "$T" "$F" '>k 27B rol AP<'
chk "$T" "$F" '>k 27B rol Tweede AP<'

T='Formule 7.1.4'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html 
chk "$T" "$F" 'href="https://extern.domein#k07Arol"'
chk "$T" "$F" 'href="https://extern.domein#k07Brol"'
chk "$T" "$F" 'href="https://extern.domein#k07BrolTweede"'
chk "$T" "$F" 'href="https://extern.domein#k27Arol"'
chk "$T" "$F" 'href="https://extern.domein#k27Brol"'
chk "$T" "$F" 'href="https://extern.domein#k27BrolTweede"'

T='Formule 7.1.5'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k07Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k07Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k07BrolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k27Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k27Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k27BrolTweede"'
F=doc/applicatieprofiel/documentatie/associaties-met-hoofdletters/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk07Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk07Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk07BrolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk27Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk27Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#hk27BrolTweede"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k07Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k07Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k07BrolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k27Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k27Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#k27BrolTweede_naam"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk07Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk07Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk07BrolTweede_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk27Arol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk27Brol_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Hk27BrolTweede_naam"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k07Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k07Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k07BrolTweede"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k27Arol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k27Brol"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#k27BrolTweede"'


T='Formule 7.2.1.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>k 07A<'
chk "$T" "$F" '>k 27 (source)<'

T='Formule 7.2.1.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html
chk "$T" "$F" '>k 07B<'
chk "$T" "$F" '>k 27 (target)<'

T='Formule 7.2.2.a'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 07A AP<'
chk "$T" "$F" '>k 27 AP (source)<'

T='Formule 7.2.2.b'
F=doc/applicatieprofiel/documentatie/associaties-met-ap-label-tags/index.html
chk "$T" "$F" '>k 07B AP<'
chk "$T" "$F" '>k 27 AP (target)<'

T='Formule 7.2.5.a'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html
chk "$T" "$F" 'href="https://extern.domein#Heeft07.k07A"'
chk "$T" "$F" 'href="https://extern.domein#Heeft07b.k07A"'
chk "$T" "$F" 'href="https://extern.domein#Heeft27.k27.source"'
chk "$T" "$F" 'href="https://extern.domein#Heeft27b.k27.source"'

T='Formule 7.2.5.b'
F=doc/applicatieprofiel/documentatie/associaties-met-uri-tags2/index.html
chk "$T" "$F" 'href="https://extern.domein#Heeft07.k07B"'
chk "$T" "$F" 'href="https://extern.domein#Heeft07b.k07B"'
chk "$T" "$F" 'href="https://extern.domein#Heeft27.k27.target"'
chk "$T" "$F" 'href="https://extern.domein#Heeft27b.k27.target"'

T='Formule 7.2.6.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft07.k07A"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft27.k27.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft07_naam.k07A_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft27_naam.k27_naam.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft07.k07A"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft27.k27.source"'
F=doc/applicatieprofiel/documentatie/associaties-met-afdaal-tags/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft07base.k07Abase"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft27base.k27base.source"'

T='Formule 7.2.6.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft07.k07B"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft27.k27.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-name-tags/index.html
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft07_naam.k07B_naam"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft27_naam.k27_naam.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-packages2/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft07.k07B"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijnanderdomein#Heeft27.k27.target"'
F=doc/applicatieprofiel/documentatie/associaties-met-afdaal-tags/index.html 
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft07base.k07Bbase"'
chk "$T" "$F" 'href="https://data.vlaanderen.be/ns/mijndomein#Heeft27base.k27base.target"'
 
T='Formule 7.2.7.a'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>Referentie naar verbonden klasse.<'

T='Formule 7.2.7.b'
F=doc/applicatieprofiel/documentatie/associaties/index.html 
chk "$T" "$F" '>Referentie naar verbonden klasse.<'
