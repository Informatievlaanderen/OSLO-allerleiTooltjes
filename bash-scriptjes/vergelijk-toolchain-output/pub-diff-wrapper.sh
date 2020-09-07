#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Wrapper rond pub-diff.sh. Ververst bestaande checkouts. Voert enkele relevante vergelijkingen uit en plaatst het resultaat in tekstbestanden met zelfverduidelijkende namen."
	echo "Voer uit na zeker één pub-diff-setup.sh."
	echo "Argumenten:"
	echo "  arg1: naam van de directory waarin de referentie branch     (uit OSLO-Generated.git) uitgecheckt staat (bvb. production)"
	echo "  arg2: naam van de directory waarin de te vergelijken branch (uit OSLO-Generated.git) uitgecheckt staat (bvb. test)"
	exit 1
fi

REF=$1
CMP=$2

set -e
#set -x

# update referentie branch
pushd $REF > /dev/null
pwd
git pull
popd > /dev/null

# update te vergelijken branch
pushd $CMP > /dev/null
pwd
git pull
popd > /dev/null

# output directory
NOW=$(date +%Y-%m-%d-%H-%M)
OUT_DIR=output/$NOW-$REF-$CMP
mkdir -p $OUT_DIR

# domains (for online browsing)
declare -A DOMAINS=(['production']='https://data.vlaanderen.be' ['test']='https://test.data.vlaanderen.be' ['test-feature-checkout']='https://otl-test.data.vlaanderen.be')


# Mogelijke commands om een browser op te starten (platform afhankelijk; pas aan...)
# Ubuntu desktop:
BROWSE=browse
# Firefox (voorbeeld) op Windows, van uit een Git Bash shell
#BROWSE="/c/Program\ Files/Mozilla\ Firefox/firefox.exe"
# Chrome (voorbeeld) op Windows, van uit een Git Bash shell
#BROWSE="/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe"

# Maak een locale link uit een HTML verwijzing
# $1: 'src="..."' or 'img="..."'
function cleaned_link() {
	local IN=$1
	# delete up to and including opening "
	local X='*="'
	IN=${IN##$X}
	# delete trailing "
	X='"'
	IN=${IN%$X}
	# delete protocol and domain
	IN=${IN##http*://*data.vlaanderen.be}
	echo $IN
}

# Maak een bestandsnaam uit een locale link, gemaakt met cleaned_link hierboven
# $1: locale link
# $2: bestand waaruit de link werd gemaakt
function filename_from_link() {
	local LINK=$1
	local FILE=$2
	if [[ -z "$LINK" ]] ; then
		local OUT=''
	elif [[ ${LINK:0:1} == '/' ]] ; then
		local FIRST_DIR=${FILE%%/*}
		local OUT=$FIRST_DIR$LINK
	else
		local BASE=${FILE##*/}
		local FULL_DIR=${FILE%$BASE}
		local OUT=$FULL_DIR$LINK
	fi
	echo $OUT
}

# Maak een script dat twee te vergelijken html bestanden naast elkaar opent in een browser.
# Het resulterend script heeft een browse command nodig, hier als $BROWSE ingevoerd.
# $1: referentiebestand
# $2: te vergeljken bestand
# $3: output file voor de vergelijking (hierop is de script bestandsnaam gebaseerd)
# $4: true [default] = online browsing (laatste versie online); false = offline browsing (bestanden uit lokale checkouts)
function make_browse_script() {
	local REF_FILE=$1
	local CMP_FILE=$2
	local SCRIPT=${3/%.txt/-browse.sh}
	local ONLINE=${4:-true}
	local UP=$(echo $SCRIPT | tr -c -d /)
	UP=${UP//"/"/"../"}
	if [[ $ONLINE == 'true' ]] ; then
		# Maak URLs van bestandsnamen
		local REF_URL=${DOMAINS[$REF]}${REF_FILE/$REF/}
		local CMP_URL=${DOMAINS[$CMP]}${CMP_FILE/$CMP/}
		# Verwijder /index.html achteraan
		local REF_URL=${REF_URL%'/index.html'}
		local CMP_URL=${CMP_URL%'/index.html'}
		# Voeg trailing slash toe voor applicatieprofielen
		if [[ $REF_URL =~ .*/applicatieprofiel/.* ]] ; then
			REF_URL=$REF_URL/
		fi
		if [[ $CMP_URL =~ .*/applicatieprofiel/.* ]] ; then
			CMP_URL=$CMP_URL/
		fi
	else
		local REF_URL=$REF_FILE
		local CMP_URL=$CMP_FILE
	fi
	echo "#!/bin/bash" > $SCRIPT
	echo "pushd $UP" >> $SCRIPT
	echo "$BROWSE $REF_URL &" >> $SCRIPT
	echo "$BROWSE $CMP_URL &" >> $SCRIPT
	echo "popd" >> $SCRIPT
	chmod +x $SCRIPT
}

# === Vanaf hier pub-diff.sh oproepen ===

# # --- Alles (te algemeen om het resultaat nog te kunnen interpreteren)
# OUT_FILE=$OUT_DIR/alles.txt
# echo ">>> Vergelijking van alle bestanden"
# echo "+++ Output naar $OUT_FILE"
# find $REF -type f -not -regex $REF/'\..*' | sort | while read f ; do (./pub-diff.sh $f ${f/$REF/$CMP} >> $OUT_FILE) ; done

# --- Vocabularia

# VOCS: vocabularia onder $REF/ns,
# eventueel overschreven met een environment variabele PUB_DIFF_VOCS
# bijvoorbeeld:
#   export PUB_DIFF_VOCS="besluit bestuur mandaat mobiliteit/trips-en-aanbod"
if [[ -z $PUB_DIFF_VOCS ]] ; then
	# vindt relatieve paden van index.html bestanden (is goede indicatie dat hier een vocabularium staat)
	VOCS_TEMP=$(find $REF/ns -mindepth 2 -name 'index.html' -printf "%P " | sed 's:/index.html::g')
	echo ">>> Mogelijk te vergelijken vocabularia: $VOCS_TEMP"
	VOCS=''
	for v in $VOCS_TEMP ; do
		# filter geversioneerde versies weg
		if [[ ! $v =~ .*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].* ]] ; then
			if [[ -z $VOCS ]] ; then
				VOCS=$v
			else
				VOCS="$VOCS $v"
			fi
		fi
	done
else
	VOCS=$PUB_DIFF_VOCS
fi

echo ">>> Te vergelijken vocabularia: $VOCS"

for v in $VOCS ; do
	OUT_FILE=$OUT_DIR/voc-${v//\//-}.txt
	echo "+++ Output naar $OUT_FILE"
	HTML_FILE=$REF/ns/$v/index.html
	make_browse_script $HTML_FILE ${HTML_FILE/$REF/$CMP} $OUT_FILE
	./pub-diff.sh      $HTML_FILE ${HTML_FILE/$REF/$CMP}      >> $OUT_FILE
	./pub-diff.sh      $REF/ns/$v.nt  $CMP/ns/$v.nt          >> $OUT_FILE
	./pub-diff.sh      $REF/ns/$v.rdf $CMP/ns/$v.rdf         >> $OUT_FILE
	./pub-diff.sh      $REF/ns/$v.ttl $CMP/ns/$v.ttl         >> $OUT_FILE
done

# --- Applicatieprofielen

# APS: applicatieprofielen onder $REF/doc/applicatieprofiel,
# eventueel overschreven met een environment variabele PUB_DIFF_APS
# bijvoorbeeld:
#   export PUB_DIFF_APS="besluit-publicatie mandatendatabank"
if [[ -z $PUB_DIFF_APS ]] ; then
	# vindt relatieve paden van index.html bestanden (is goede indicatie dat hier een vocabularium staat)
	APS_TEMP=$(find $REF/doc/applicatieprofiel -mindepth 2 -name 'index.html' -printf "%P " | sed 's:/index.html::g')
	echo ">>> Mogelijk te vergelijken applicatieprofielen: $APS_TEMP"
	APS=''
	for a in $APS_TEMP ; do
		# filter geversioneerde versies weg
		if [[ ! $a =~ .*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].* ]] ; then
			if [[ -z $APS ]] ; then
				APS=$a
			else
				APS="$APS $a"
			fi
		fi
	done
else
	APS=$PUB_DIFF_APS
fi

echo ">>> Te vergelijken applicatieprofielen: $APS"
for a in $APS ; do
	OUT_FILE=$OUT_DIR/ap-${a//\//-}.txt
	echo "+++ Output naar $OUT_FILE"
	HTML_FILE=$REF/doc/applicatieprofiel/${a}/index.html
	make_browse_script $HTML_FILE ${HTML_FILE/$REF/$CMP} $OUT_FILE
	./pub-diff.sh $HTML_FILE ${HTML_FILE/$REF/$CMP} >> $OUT_FILE
	if [[ -e $HTML_FILE ]] ; then
		REF_HTML_FILE=$HTML_FILE
		CMP_HTML_FILE=${HTML_FILE/$REF/$CMP}

		REF_OVERVIEW_LINK=$(cleaned_link $(grep -o 'src=".*overview\.jpg"' $REF_HTML_FILE || true))
		REF_OVERVIEW_FILE=$(filename_from_link $REF_OVERVIEW_LINK $REF_HTML_FILE)
		if [[ -z "$REF_OVERVIEW_FILE" ]] ; then
			# allicht een "objectcataloog" van openbaar domein
			echo "=== Geen link naar een overview.jpg in $REF_HTML_FILE, dus ook geen vergelijking...">> $OUT_FILE
		else
			CMP_OVERVIEW_LINK=$(cleaned_link $(grep -o 'src=".*overview\.jpg"' $CMP_HTML_FILE || true))
			CMP_OVERVIEW_FILE=$(filename_from_link $CMP_OVERVIEW_LINK $CMP_HTML_FILE)
			./pub-diff.sh $REF_OVERVIEW_FILE $CMP_OVERVIEW_FILE >> $OUT_FILE
		fi

		REF_CONTEXT_LINK=$(cleaned_link $(grep -o 'href=".*\.jsonld"' $REF_HTML_FILE || true))
		# default voor ontbrekende context link (weet niet of dit kan voorkomen)
		if [[ -z "$REF_CONTEXT_LINK" ]] ; then
			REF_CONTEXT_LINK=/context/${a}.jsonld
			echo "=== Geen link naar een context file in $REF_HTML_FILE, gebruik default bestandsnaam $REF_CONTEXT_LINK">> $OUT_FILE
		fi
		REF_CONTEXT_FILE=$(filename_from_link $REF_CONTEXT_LINK $REF_HTML_FILE)
		CMP_CONTEXT_LINK=$(cleaned_link $(grep -o 'href=".*\.jsonld"' $CMP_HTML_FILE || true))
		# default voor ontbrekende context link (weet niet of dit kan voorkomen)
		if [[ -z "$CMP_CONTEXT_LINK" ]] ; then
			CMP_CONTEXT_LINK=/context/${a}.jsonld
			echo "=== Geen link naar een context file in $CMP_HTML_FILE, gebruik default bestandsnaam $CMP_CONTEXT_LINK">> $OUT_FILE
		fi
		CMP_CONTEXT_FILE=$(filename_from_link $CMP_CONTEXT_LINK $CMP_HTML_FILE)
		./pub-diff.sh $REF_CONTEXT_FILE $CMP_CONTEXT_FILE >> $OUT_FILE

		REF_SHACL_LINK=$(cleaned_link $(grep -o 'href=".*\.ttl"' $REF_HTML_FILE || true))
		# default voor ontbrekende shacl link (komt voor in oude applicatieprofielen)
		if [[ -z "$REF_SHACL_LINK" ]] ; then
			REF_SHACL_LINK=/shacl/${a}-SHACL.ttl
			echo "=== Geen link naar een SHACL file in $REF_HTML_FILE, gebruik default bestandsnaam $REF_SHACL_LINK">> $OUT_FILE
		fi
		REF_SHACL_FILE=$(filename_from_link $REF_SHACL_LINK $REF_HTML_FILE)
		CMP_SHACL_LINK=$(cleaned_link $(grep -o 'href=".*\.ttl"' $CMP_HTML_FILE || true))
		# default voor ontbrekende shacl link (komt voor in oude applicatieprofielen)
		if [[ -z "$CMP_SHACL_LINK" ]] ; then
			CMP_SHACL_LINK=/shacl/${a}-SHACL.ttl
			echo "=== Geen link naar een SHACL file in $CMP_HTML_FILE, gebruik default bestandsnaam $CMP_SHACL_LINK">> $OUT_FILE
		fi
		CMP_SHACL_FILE=$(filename_from_link $CMP_SHACL_LINK $CMP_HTML_FILE)
		./pub-diff.sh $REF_SHACL_FILE $CMP_SHACL_FILE >> $OUT_FILE
	fi
done
