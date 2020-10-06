# WalkOver

## Inleiding
Dit is een frameworkje om de inhoud van Enterprise Architect (EA) modellen binnen OSLO context te scriptmatig te kunnen bewerken.

Het frameworkje is afgeleid van de tool [TagsAndNotes](../TagsAndNotes.README.md)** die elders in deze repository is terug te vinden.

De basis is terug te vinden in **WalkOverPrototype.xlsm**.

Deze basis is niet invasief op de inhoud van het model waarop het inwerkt.

Enkele van deze basis afgeleide voorbeelden zijn te vinden in de subfolders van **implementaties**.

## Handleiding

### Voorbereiding
Open een van de .xlsm bestanden.

Bij het voor de eerste keer openen van dit bestand wordt allicht een beveiligingswaarschuwing gegeven.
Klik dan op "Enable Content".

Inspecteer de code door in Excel het menu **Developer** **Visual Basic** te openen. De methodes **Do...** in de module **CEAPackageConnector** doen de effectieve bewerkingen.
Ga alleen verder als dit echt is wat je wil uitvoeren.

### Technische stappen om de macro operationeel te maken
Zie hiervoor de gelijknamige paragraaf in [TagsAndNotes](../TagsAndNotes.README.md).

### Uitvoering
Het resultaat van deze bewerking is een mogelijks gewijzigd EA model en mogelijk output in het **Visual Basic Immediate** window.

Stappen:
- Open het menu **Developer**, **Visual Basic** en open daarin het **Immediate** window.
- Open het menu Add-ins en klik op **Walk over content in EA (!!!)**.
- Doe zoals de prompts vragen:
  - Open in EA het modelbestand waarop gewerkt moet worden; opgelet: er mag maar één instance van EA open staan.
  - Selecteer in de EA project browser:
    - voor diagram-gericht werken: het diagram waaruit gelezen moet worden.
    - voor package-gericht werken: het package waaruit gelezen moet worden.
- Wacht op de melding dat de bewerking klaar is.
- Inspecteer het mogelijks gewijzigde model in EA.
- Bekijk de logging output in het Immediate window.

## Zelf nieuwe scripts maken**
- Maak een kopie van een van de subfolders onder **implementaties**; geef indicatieve naam aan folder en bestanden.
- Pas de **Do...** methodes in de module **CEAPackageConnector** aan naar wens. Tracht een Debug.Print statement uit te voeren in lijn van het voorbeeld, in geval iets werd aangepast.
- Exporteer de module **CEAPackageConnector** naar de onderliggende **src** folder.
- Geef op z'n minst een indicatieve commentaar regel in de Doc sheet van het .xlsm bestand.
- Pas het .EAP bestand tot het een valabele input is om de macro te testen.
- Kopieer het .EAP bestand naar een tijdelijk bestand en gebruik dit om de macro te testen.
