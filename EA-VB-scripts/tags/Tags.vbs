' VOORAFGAANDE OPMERKING
' DIT SCRIPT IS OBSOLETE (NU ER EEN TagsAndNotes.xlsm BESTAAT).
' GEBRUIK DIT ENKEL NOG EVENTUEEL VOOR DE FUNCTIONALITEIT VAN DeleteTagsOnNamelessConnectors
'
' Naam: Tags.vbs
' Doel: Tags toevoegen/verwijderen/tonen in elementen, attributen, connectoren en connector uiteinden in een package.
'       Optioneel kunnen ook notes op deze objecten worden getoond.
' Datum: 2020-05-06
'
' Opmerking:
' - wees voorzichting bij het toevoegen van tags (voor uri's bijvoorbeeld): tags worden overal op gezet!
'
' Gebruik:
' - In main staan voor alle mogelijkheden voorbeeldoproepen van oproepbare subs; activeer 'calls' en pas aan volgens behoefte
' - Selecteer in de EA project browser het package waarop gewerkt moet worden
' - Run
' - Copy/Paste eventueel de systeem output naar Excel

option explicit

!INC Local Scripts.EAConstants-VBScript

'----- utilities

' Print een regel met een naam en een waarde, voorafgegaan door een eenduidige aanduiding.
' De regel bevat drie velden, door tabs gescheiden, ideaal voor copy-paste in Excel
' Voor lege waarden wordt geen regel geprint.
'
' De eenduidige aanduiding vooraan bestaat uit onderdelen opgebouwd uit de parameter disamb
' De verschillende onderdelen worden gescheiden door een "|"
' Elk onderdeel wordt voorafgegaan door een prefix letter en een ":". Prefix letters:
'   k: klasse
'	d: datatype
'   e: enumeratie
'   a: attribuut
'   c: connector
'   r: rol
' Parameters:
'   name: naam van de waarde
'   value: de waarde
'   disamb: array met opeenvolgen levels te gebruiken in de eenduidige aanduiding
'     ondersteunde types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
sub PrintDisambiguated( name, value, disamb )
	if Len( value ) > 0 then
		dim disambString
		disambString = ""
		dim obj
		for each obj in disamb
			if disambString <> "" then
				disambString = disambString & "|"
			end if
			select case obj.ObjectType
			case otElement
				select case LCase( obj.MetaType )
				case "datatype"
					disambString = disambString & "d:" & obj.Name
				case "enumeration"
					disambString = disambString & "e:" & obj.Name
				case else
					disambString = disambString & "k:" & obj.Name
				end select
			case otAttribute
				disambString = disambString & "a:" & obj.Name
			case otConnector
				disambString = disambString & "c:" & obj.Name
			case otConnectorEnd
				disambString = disambString & "r:" & obj.Role
			end select
		next
		Session.Output( disambString & vbTab & name & vbTab & value )
	end if
end sub

' Haal een tag object op
' Parameters:
'   owner: object dat de tag bevat
'          ondersteund: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: naam van de tag
' Return:
'   corresponderend object, respectievelijk: EA.TaggedValue, EA.AttributeTag, EA.ConnectorTag, EA.RoleTag
function GetTag( owner, name )
	set GetTag = nothing
	if not owner is nothing and Len( name ) > 0 then
		'ter info: owner.TaggedValues.GetByName( name ) vermeden wegens instabiliteiten
		select case owner.ObjectType
		case otElement
			dim tv as EA.TaggedValue
			for each tv in owner.TaggedValues
				if tv.Name = name then
					set GetTag = tv
					exit for
				end if
			next
		case otAttribute
			dim tv1 as EA.AttributeTag
			for each tv1 in owner.TaggedValues
				if tv1.Name = name then
					set GetTag = tv1
					exit for
				end if
			next
		case otConnector
			dim tv2 as EA.ConnectorTag
			for each tv2 in owner.TaggedValues
				if tv2.Name = name then
					set GetTag = tv2
					exit for
				end if
			next
		case otConnectorEnd
			dim tv3 as EA.RoleTag
			for each tv3 in owner.TaggedValues
				if tv3.Tag = name then
					set GetTag = tv3
					exit for
				end if
			next
		end select
	end if
end function

' Voeg een tag object toe als het nog niet bestaat
' Parameters:
'   owner: object dat de tag zal bevatten
'          ondersteund: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: naam van de tag
'   value: waarde voor de tag
' Return: true indien tag object toegevoegd
function AddTag( owner, name, value )
	AddTag = false

	dim tv
	set tv = GetTag( owner, name )
	if tv is nothing then
		' merk op dat de truuk met NOTE niet lukt voor rollen, omdat RoleTag.Notes niet voorzien is in EA's API
		' maar blijkbaar is dat ook niet nodig want een RoleTag.value mag blijkbaar langer zijn dan 255 karakters (getest met 512)
		if Len( value ) > 255 and owner.ObjectType <> otConnectorEnd then
			set tv = owner.TaggedValues.AddNew( name, "NOTE" )
			tv.Notes = value
		else 
			set tv = owner.TaggedValues.AddNew( name, value )
		end if
		call tv.Update()
		call owner.TaggedValues.Refresh()
		AddTag = true
	end if
end function

' Wrapper rond AddTag die in geval van toevoeging PrintDisambiguated oproept
' Parameter beschrijving: zie AddTag en PrintDisambiguated
function AddTagVerbose( owner, name, value, disamb )
	AddTagVerbose = AddTag( owner, name, value )

	if AddTagVerbose then
		call PrintDisambiguated( name, "(added:)" & value, disamb )
	end if
end function

' Verwijder een tag object als het bestaat.
' Als er meerdere tag objecten met dezelfde naam binnen de owner bestaan: verwijder ze allemaal
' Parameters:
'   owner: object dat de tag(s) bevat
'          ondersteund: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: naam van de tag
' Return: true indien tag object verwijderd
function DeleteTag( owner, name )
	DeleteTag = false

	if not owner is nothing and Len( name ) > 0 then
		dim tvs as EA.Collection
		set tvs = owner.TaggedValues
		dim i, tv
		select case owner.ObjectType
		case otConnectorEnd
			for i = tvs.Count - 1 to 0 step -1
				set tv = tvs.GetAt( i )
				if tv.Tag = name then
					call owner.TaggedValues.DeleteAt( i, FALSE )
					DeleteTag = true
				end if
			next
		case else
			for i = tvs.Count - 1 to 0 step -1
				set tv = tvs.GetAt( i )
				if tv.Name = name then
					call owner.TaggedValues.DeleteAt( i, FALSE )
					DeleteTag = true
				end if
			next
		end select
		call owner.TaggedValues.Refresh()
	end if
end function

' Wrapper rond DeleteTag die in geval van verwijdering PrintDisambiguated oproept
' Parameter beschrijving: zie DeleteTag en PrintDisambiguated
function DeleteTagVerbose( owner, name, disamb )
	DeleteTagVerbose = DeleteTag( owner, name )

	if DeleteTagVerbose then
		call PrintDisambiguated( name, "(deleted)", disamb )
	end if
end function

' Haal een tag waarde op
' Parameters:
'   owner: object dat de tag bevat
'          ondersteund: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: naam van de tag
'   defaultValue: waarde terug te geven als de tag niet bestaat
' Return:
'   String
function GetTagValue( owner, name, defaultValue )
	GetTagValue = defaultValue
	
	dim tv
	set tv = GetTag( owner, name )
	if not tv is nothing then
		' merk op dat de truuk met NOTE niet lukt voor rollen, omdat RoleTag.Notes niet voorzien is in EA's API
		' maar blijkbaar is dat ook niet nodig want een RoleTag.value mag blijkbaar langer zijn dan 255 karakters (getest met 512)
		if tv.Value = "NOTE" and owner.ObjectType <> otConnectorEnd then
			GetTagValue = tv.Notes
		else
			GetTagValue = tv.Value
		end if
	end if
end function

' Bereken waarde voor een tag
' Parameters:
'   value: waarde voor de tag, met mogelijke @{} macro's:
'     @{name}: wordt vervangen door de UML naam van het element
'     @{name-to-label}: wordt vervangen door de UML naam van het element,
'                       nadat deze geformateerd wordt zoals gebruikelijk voor een label:
'                       - caret symbool vooraan wordt eerst en vooral verwijderd
'                       - er wordt gesplitst in woorden (gescheiden met een spatie),
'                         woordgrens is tussn een kleine letter en een er op volgende grote letter of cijfer
'                         en ook tussen een cijfer en een volgende letter
'                       - bij klassen, datatypes en enumeraties wordt de eerste letter van elk woord een grote letter
'                       - anders wordt de eerste letter van elk woord een kleine letter
'   parent: object waarbinnen de tag zich bevindt; ondersteund wordt:
'           EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
' Return:
'   String
function CalculateTagValue( value, parent )
	CalculateTagValue = value

	dim umlName, firstUpper
	select case parent.ObjectType
	case otElement
		umlName = parent.Name
		firstUpper = true
	case otAttribute
		umlName = parent.Name
		firstUpper = false
	case otConnector
		umlName = parent.Name
		firstUpper = false
	case otConnectorEnd
		umlName = parent.Role
		firstUpper = false
	end select

	if InStr( value, "@{name}" ) then
		CalculateTagValue = Replace( value, "@{name}", umlName )
	end if
	if Instr( value, "@{name-to-label}" ) then
		dim newName
		newName = ""
		if Len( umlName ) > 0 then
			dim i0, cPrevious, i, c, newWord
			' verwijder mogelijke leidende caret
			if Mid( umlName, 1, 1 ) = "^" then
				i0 = 2
			else
				i0 = 1
			end if
			' eerste karakter
			cPrevious = Mid( umlName, i0, 1)
			if firstUpper then
				newName = newName & UCase( cPrevious )
			else
				newName = newName & LCase( cPrevious )
			end if
			' volgende karakters
			for i = i0 + 1 to Len( umlName )
				c = Mid( umlName, i, 1 )
				newWord = false
				if  IsNumeric( cPrevious ) then
					if not IsNumeric( c ) then
						newWord = true
					end if
				else
					if cPrevious = LCase( cPrevious ) then
						if IsNumeric( c ) or c = UCase( c ) then
							newWord = true
						end if
					end if
				end if
				if newWord then
					if firstUpper then
						newName = newName & " " & UCase( c )
					else
						newName = newName & " " & LCase( c )
					end if
				else
					newName = newName & c
				end if
				cPrevious = c
			next
		end if
		CalculateTagValue = Replace( value, "@{name-to-label}", newName )
	end if
end function

' Haal een notes veld op
' Parameters:
'   owner: object dat het notes veld bevat
'          ondersteund: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   defaultValue: waarde terug te geven als het notes veld leeg is
' Return:
'   String
function GetNotes( owner, defaultValue )
	GetNotes = defaultValue
	if not owner is nothing then
		select case owner.ObjectType
		case otElement, otAttribute, otConnector
			GetNotes = owner.Notes
		case otConnectorEnd
			GetNotes = owner.RoleNote
		end select
	end if
	if Len( GetNotes ) = 0 then
		GetNotes = defaultValue
	end if
end function

'----- subs voor direct gebruik in main

function GetElementsToWorkOn()
	' Bepaal het package waarop te werken: het geselecteerde package in EA's project browser
	dim package as EA.Package
	set package = Repository.GetTreeSelectedPackage()
	' Haal alle elementen op uit het package
	dim query
	query= "select to.object_id FROM t_object to WHERE to.package_id=" & package.PackageID
	set GetElementsToWorkOn = Repository.GetElementSet( query, 2 )
	Session.Output( "Werkend op package " & package.PackageID &", met naam " & package.Name & " (" & GetElementsToWorkOn.Count & " elementen)" )
end function

' Voeg tags toe aan elementen, attributen, connectoren en connector uiteinden
' Parameters:
'   elements: EA.Collection die de te behandelen elementen bevat
'   name: alleen tags met deze name wordt behandeld
'   value: waarde voor de tag met mogelijke @{} macro's (zie CalculateTagValue)
sub AddTags( elements, name, value )
	dim element
	for each element in elements
		if element.type="Class" OR element.type="Enumeration" OR element.type="DataType" then
			call AddTagVerbose( element, name, CalculateTagValue( value, element ), Array( element ) )
			dim attributes
			set attributes = element.Attributes
			dim attribute
			for each attribute in attributes
				call AddTagVerbose( attribute, name, CalculateTagValue( value, attribute ), Array( element, attribute ) )
			next
			dim connectors
			set connectors = element.Connectors
			dim connector
			for each connector in connectors
				if connector.Type ="Association" OR connector.Type ="Aggregation" OR connector.Type ="Composition" then
					' Behandeling van uit het element aan één kant (source kant) volstaat
					if connector.ClientID = element.ElementID then
						dim otherElement as EA.Element
						set otherElement = Repository.GetElementByID( connector.SupplierID )
						' Behandeling van de connector zelf (tenzij hij naamloos is)
						if Len( connector.Name ) > 0 then
							call AddTagVerbose( connector, name, CalculateTagValue( value, connector ), Array( element, connector, otherElement ) )
						end if
						' Behandeling van de rol aan de target kant (tenzij ze naamloos is)
						if Len( connector.SupplierEnd.Role ) > 0 then
							call AddTagVerbose( connector.SupplierEnd, name, CalculateTagValue( value, connector.SupplierEnd ), Array( element, connector.SupplierEnd, otherElement ) )
						end if
						' Behandeling van de rol aan de source kant (tenzij ze naamloos is)
						if Len( connector.ClientEnd.Role ) > 0 then
							call AddTagVerbose( connector.ClientEnd, name, CalculateTagValue( value, connector.ClientEnd ), Array( otherElement, connector.ClientEnd, element ) )
						end if
					end if
				end if
			next
		end if
   next
end sub

' Verwijdert tags uit elementen, attributen, connectoren en connector uiteinden
' Parameters:
'   elements: EA.Collection die de te behandelen elementen bevat
'   name: alleen tags met deze name wordt behandeld
sub DeleteTags( elements, name )
	dim element
	for each element in elements
		if element.type="Class" OR element.type="Enumeration" OR element.type="DataType" then
			call DeleteTagVerbose( element, name, Array( element ) )
			dim attributes
			set attributes = element.Attributes
			dim attribute
			for each attribute in attributes
				call DeleteTagVerbose( attribute, name, Array( element, attribute ) )
			next
			dim connectors
			set connectors = element.Connectors
			dim connector
			for each connector in connectors
				if connector.Type ="Association" OR connector.Type ="Aggregation" OR connector.Type ="Composition" then
					' Behandeling van uit het element aan één kant (source kant) volstaat
					if connector.ClientID = element.ElementID then
						dim otherElement as EA.Element
						set otherElement = Repository.GetElementByID( connector.SupplierID )
						' Behandeling van de connector zelf (tenzij hij naamloos is)
						if Len( connector.Name ) > 0 then
							call DeleteTagVerbose( connector, name, Array( element, connector, otherElement ) )
						end if
						' Behandeling van de rol aan de target kant (tenzij ze naamloos is)
						if Len( connector.SupplierEnd.Role ) > 0 then
							call DeleteTagVerbose( connector.SupplierEnd, name, Array( element, connector.SupplierEnd, otherElement ) )
						end if
						' Behandeling van de rol aan de source kant (tenzij ze naamloos is)
						if Len( connector.ClientEnd.Role ) > 0 then
							call DeleteTagVerbose( connector.ClientEnd, name, Array( otherElement, connector.ClientEnd, element ) )
						end if
					end if
				end if
			next
		end if
   next
end sub

' Verwijdert tags uit connectoren zonder naam
' (als correctie op op werking van oorspronkelijke z_TagsOrigineelVoorbeeldGeertThijs, die naamloze connectoren niet oversloeg)
' Parameters:
'   elements: EA.Collection die de te behandelen elementen bevat
'   name: alleen tags met deze name wordt behandeld
sub DeleteTagsOnNamelessConnectors( elements, name )
	dim element
	for each element in elements
		if element.type="Class" OR element.type="Enumeration" OR element.type="DataType" then
			dim connectors
			set connectors = element.Connectors
			dim connector
			for each connector in connectors
				if connector.Type ="Association" OR connector.Type ="Aggregation" OR connector.Type ="Composition" then
					' Behandeling van uit het element aan één kant (source kant) volstaat
					if connector.ClientID = element.ElementID then
						' Behandeling van de connector zelf (enkel als hij naamloos is)
						if Len( connector.Name ) = 0 then
							dim otherElement as EA.Element
							set otherElement = Repository.GetElementByID( connector.SupplierID )
							call DeleteTagVerbose( connector, name, Array( element, connector, otherElement) )
						end if
					end if
				end if
			next
		end if
   next
end sub

' Toont tags in elementen, attributen, connectoren en connector uiteinden
' Kan ook de notes op het object dat de tags bevat tonen
' Parameters:
'   elements: EA.Collection die de te behandelen elementen bevat
'   notesToo: indien true worden ook de notes op de parent van de tags getoond
sub ListTags( elements, notesToo )
	dim tagNotFound
	tagNotFound = ""
	dim notesNotFound
	notesNotFound = "-"
	dim element
	dim tv
	for each element in elements
		if element.type="Class" OR element.type="Enumeration" OR element.type="DataType" then
			if notesToo then
				call PrintDisambiguated( "(notes)", GetNotes( element, notesNotFound ), Array( element ) )
			end if
			for each tv in element.TaggedValues
				call PrintDisambiguated( tv.Name, GetTagValue( element, tv.Name, tagNotFound ), Array( element ) )
			next
			dim attributes
			set attributes = element.Attributes
			dim attribute
			for each attribute in attributes
				if notesToo then
					call PrintDisambiguated( "(notes)", GetNotes( attribute, notesNotFound ), Array( element, attribute ) )
				end if
				for each tv in attribute.TaggedValues
					call PrintDisambiguated( tv.Name, GetTagValue( attribute, tv.Name, tagNotFound ), Array( element, attribute ) )
				next
			next
			dim connectors
			set connectors = element.Connectors
			dim connector
			for each connector in connectors
				if connector.Type ="Association" OR connector.Type ="Aggregation" OR connector.Type ="Composition" then
					' Behandeling van uit het element aan één kant (source kant) volstaat
					if connector.ClientID = element.ElementID then
						dim otherElement as EA.Element
						set otherElement = Repository.GetElementByID( connector.SupplierID )
						' Behandeling van de connector zelf (tenzij hij naamloos is)
						if Len( connector.Name ) > 0 then
							if notesToo then
								call PrintDisambiguated( "(notes)", GetNotes( connector, notesNotFound ), Array( element, connector, otherElement ) )
							end if
							for each tv in connector.TaggedValues
								call PrintDisambiguated( tv.Name, GetTagValue( connector, tv.Name, tagNotFound ), Array( element, connector, otherElement ) )
							next
						end if
						' Behandeling van de rol aan de target kant (tenzij ze naamloos is)
						if Len( connector.SupplierEnd.Role ) > 0 then
							if notesToo then
								call PrintDisambiguated( "(notes)", GetNotes( connector.SupplierEnd, notesNotFound ), Array( element, connector.SupplierEnd, otherElement ) )
							end if
							for each tv in connector.SupplierEnd.TaggedValues
								call PrintDisambiguated( tv.Tag, GetTagValue( connector.SupplierEnd, tv.Tag, tagNotFound ), Array( element, connector.SupplierEnd, otherElement ) )
							next
						end if
						' Behandeling van de rol aan de source kant (tenzij ze naamloos is)
						if Len( connector.ClientEnd.Role ) > 0 then
							if notesToo then
								call PrintDisambiguated( "(notes)", GetNotes( connector.ClientEnd, notesNotFound ), Array( otherElement, connector.ClientEnd, element ) )
							end if
							for each tv in connector.ClientEnd.TaggedValues
								call PrintDisambiguated( tv.Tag, GetTagValue( connector.ClientEnd, tv.Tag, tagNotFound ), Array( otherElement, connector.ClientEnd, element ) )
							next
						end if
					end if
				end if
			next
		end if
   next
end sub

'---- main

sub main
	' Maak het script output window zichtbaar
	Repository.EnsureOutputVisible( "Script" )

	dim elements as EA.Collection
	set elements = GetElementsToWorkOn()
	dim answer

	' Verwijdert eerder aanwezige tags
	'answer = Session.Prompt( "Bestaande tags verwijderen?", promptYESNO )
	'if answer = resultYes then
	'	call DeleteTags( elements, "ap-label-nl" )
	'	call DeleteTags( elements, "ap-definition-nl" )
	'	call DeleteTags( elements, "ap-usageNote-nl" )
	'	call DeleteTags( elements, "uri" )
	'end if

	' Verwijdert eerder aanwezige tags OP NAAMLOZE CONNECTOREN, als correctie op vroegere implementatie van AddTags
	answer = Session.Prompt( "Bestaande tags op naamloze connectoren verwijderen?", promptYESNO )
	if answer = resultYes then
		call DeleteTagsOnNamelessConnectors( elements, "ap-label-nl" )
		call DeleteTagsOnNamelessConnectors( elements, "ap-definition-nl" )
		call DeleteTagsOnNamelessConnectors( elements, "ap-usageNote-nl" )
		call DeleteTagsOnNamelessConnectors( elements, "uri" )
	end if
	
	' Voegt tags toe indien ze nog niet aanwezig zijn, met aangeduide waarde (die eventueel @{} macros kan bevatten, zie CalculateTagValue)
	'answer = Session.Prompt( "Nieuwe tags toevoegen?", promptYESNO )
	'if answer = resultYes then
	'	call AddTags( elements, "ap-label-nl",      "@{name-to-label}" )
	'	call AddTags( elements, "ap-definition-nl", "TO DO" )
	'	call AddTags( elements, "ap-usageNote-nl",  "Dit is een string van 512 karakters, eindigend op een uitroepteken, ook al zie je dat niet meteen in EA's system output. Copy/Paste en je zal wel zien.........................................................................................................................................................................................................................................................................................................................................................................!" )
	'	call AddTags( elements, "uri",              "https://wherever/ns#@{name}" )
	'end if
	
	' Toont alle aanwezige tags op objecten, eventueel voorafgegaan door notes op die objecten
	call ListTags( elements, true )

	Session.output( "Klaar." )

end sub

main
	  
