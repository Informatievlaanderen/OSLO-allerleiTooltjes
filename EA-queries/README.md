# EA-queries

**Opmerking vooraf.**
**De meeste van deze queries zijn draken om te onderhouden en hebben bovendien geen zin meer na het beschikbaar zijn van TagsAndNotes.xlsm in deze repository.**
**Bovendien is geen enkele query aangepast voor rollen.**
**Mocht een of andere query of een uitbreiding er op nodig zijn, dan verdient het aanbeveling om in plaats een afgeleide van TagsAndNotes.xlsm te maken die deze functionaliteit makkelijk kan ondersteunen.**

Enkele SQL queries om te gebruiken in [Enterprise Architect](https://sparxsystems.com/products/ea/) (EA).

Elke query bevindt zich in een **.sql** bestand en is gedocumenteerd met commentaarlijnen (startend met --).

Wat hij doet is af te leiden uit de bestandsnaam en deze commentaarlijnen.

Van elk .sql bestand is een versie zonder commentaarlijnen beschikbaar in een overeenkomstig bestand **.sql-nc**.
Dit is nodig ten behoeve van import in EA.

**Run voor elk nieuw / gewijzigd .sql bestand `./update-all-nc.sh` om de .sql-nc versie te creëren / updaten.**

## Hoe een .sql bestand importeren in EA

NOTE: een geïmporteerde query wordt bewaard in de EA omgeving op je computer (niet ergens centraal of in een .eap bestand).

Kopieer de inhoud van het **.sql-nc** bestand naar het clipboard.

Open Enterprise Architect.

Open het **Find in Project** Window (Via menu: Edit > Search In Model).

Klik op het **New Search** icoon.

Geef een naam op voor de nieuwe search (gebruik de bestandsnaam zonder extensie), selecteer **SQL Editor** en klik **OK**.

Paste de clipboard inhoud in de **Query Builder** tab, die nu zou moeten open staan.

**Save**.

## Hoe een query runnen in EA

In EA, selecteer een van eerder geïmporteerde queries. Je vindt ze in het **Find in Project** Window, onder de categorie **MySearches**.

* Als de query een `<Search Term>` bevat, geef een van toepassing zijnde waarde in het veld `<Search Term>`. Het originele .sql bestand documenteert wat verwacht wordt.
* Als de query een macro bevat die verwijst naar de structuur in de Project Browser (bvb. `#Branch#`, `#Package#`), selecteer het van toepassing zijn onderdeel in de Project Browser. Het originele .sql bestand documenteert wat verwacht wordt.

Klik op het **Run** icoon.

Kopieer eventueel het resultaat uit het resultaat window en plak het in Excel of een tekst editor.

## Verdere informatie
* Gebruikte macro's (bvb.. #Branch#): zie **Create SQL Search** in https://sparxsystems.com/enterprise_architect_user_guide/12.1/building_models/creating_filters.html.
