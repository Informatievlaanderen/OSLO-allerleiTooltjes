# vergelijk-toolchain-output

Tooltjes gemaakt om de publicatie output van de OSLO toolchain te vergelijken.

Clone deze repo en voer deze scriptjes uit in deze directory, in een bash shell.

Voor gedetailleerde uitleg over wat de scriptjes juist doen, voer ze uit zonder parameters.

Lees verder om te weten hoe de output te beperken tot bepaalde vocabularia en applicatieprofielen.

## Recente aanpassingen
- Toevoeging browse scriptjes in de output directory.
- Tverschrijven te vergelijken vocabularia en applicatieprofielen met environment variabelen in plaats van door script aan te passen.

## Voorbeeld gebruik

Doe dit éénmalig:
```
 ./pub-diff-setup.sh production test
```
Als resultaat komen hieruit twee subdirectories onder de current directory (production en test).
Het zijn checkouts van de gelijknamige branches van https://github.com/Informatievlaanderen/OSLO-Generated.git.

Doe dit telkens je opnieuw wil vergelijken:
```
./pub-diff-wrapper.sh production test
```
Op het scherm is de vooruitgang te zien.

De output van de vergelijkingen komt terecht in een subdirectory output/... onder current directory.

De naam van deze subdirectory bevat een timestamp en een indicatie van de vergeleken branches (bvb. 2020-03-30-18-55-production-test).

In de output bestanden `*.txt` wordt de output van de vergelijking van een paar bestanden telkens voorafgegaan door een header regel
die begint met `===`.
Als een paar vergeleken bestanden identiek zijn, is er verder geen output te zien tot aan de volgende `===`.

Als extraatje worden in de output directory ook scriptjes `*-browse.sh` aangemaakt.
Als je er eentje uitvoert, opent je browser met de twee te vergelijken html documenten naast elkaar.

## Opmerkingen

Het script `pub-diff.sh` bevat de logica om twee bestanden te vergelijken.

Het script `pub-diff-wrapper.sh` kiest de bestanden en roept `pub-diff.sh` aan zoveel als nodig.

Om de te vergelijken vocabularia en applicatieprofielen in `pub-diff-wrapper.sh`te beperken tot je persoonlijke scope,
zet environment variabelen zoals te zien in voorbeeld bestand `vars-martin`.
Doe dit weer teniet met `vars-unset`.


Betreffende de scriptjes `*-browse.sh`: de browser opent de html documenten online en niet de lokale bestanden uit de checkouts.
Dit maakt het mogelijk om in Chrome de extensie [HTML Diff Check Tool](https://chrome.google.com/webstore/detail/html-diff-check-tool/fjbonpakihikkocmockbkndhooihpijo) te gebruiken.
Deze werkt namelijk niet op offline bestanden.

## Aanpassingen die je zelf kan/moet doen op je locale versie

Om de browse scriptjes `*-browse.sh` te laten werken voor jouw platform,
kan het nodig zijn om de definitie van `BROWSE` aan te passen in `pub-diff-wrapper.sh`.
Er zijn al voorbeelden beschikbaar voor Ubuntu desktop en voor Bash Shell op Windows.
