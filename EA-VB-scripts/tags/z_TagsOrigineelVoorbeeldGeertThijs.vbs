' Naam: z_TagsOrigineelVoorbeeldGeertThijs.vbs
' Doel: OUDE VERSIE, NIET MEER GEBRUIKEN!
' Datum: 2017-06-19
'
' Dit is het originele script ontvangen van Geert Thijs.
' Enige toegevoegde waarde van mij (Martin) hier is de formatering.
'
' Commentaar van Geert bij dit script:
'	Is voor package-id=3 en om een ap-label-nl tag te creëren met de naam vh element, dus theQuery aanpassen naar wens.
'	Je maakt hiermee voor alle elementen een tag aan. Beetje onhandig voor bv de name-tag want als je de naam vh element ih diagram aanpast moet je nu twee tags aanpassen: de name-tag en de label-tag. (Evt overwegen om theQuery zodanig aan te passen dat hij zich beperkt tot de elementen met een caret vor de naam).
'	En uiteraard moet die caret dan ook nog eens uit de naam gehaald worden om de name-tag te genereren.
'	Script kan ook gebruikt worden om evt ontbrekende tags bij te creëren, diegene die er al staan worden ongemoeid gelaten.
'	En zoals gezegd: momenteel negeert het script rolnamen, zou leuk zijn als je het voor rolnamen kon uitbreiden.

option explicit

!INC Local Scripts.EAConstants-VBScript

function GetElementTaggedValue( theElement, taggedValueName, defaultValue )
	GetElementTaggedValue = defaultValue

	if not theElement is nothing and Len(taggedValueName) > 0 then
		dim taggedValue as EA.TaggedValue
		set taggedValue = theElement.TaggedValues.GetByName( taggedValueName )
		if not taggedValue is nothing then
			GetElementTaggedValue = taggedValue.Value
		end if
	end if
end function

function GetAttributeTaggedValue( theAttribute, taggedValueName, defaultValue )
	GetAttributeTaggedValue = defaultValue

	if not theAttribute is nothing and Len(taggedValueName) > 0 then
		dim taggedValue as EA.AttributeTag
		dim selectedTaggedValue as EA.AttributeTag
		set selectedTaggedValue = nothing
		'loop omdat TaggedValues.getByName niet werkt bij tagged values van attributen
		for each taggedValue in theAttribute.TaggedValues
			if taggedValue.name = taggedValueName then
				set selectedTaggedValue = taggedValue
				exit for
			end if
		next
		if not selectedTaggedValue is nothing then
			GetAttributeTaggedValue = selectedTaggedValue.Value
		end if
	end if
end function

function GetConnectorTaggedValue( theConnector, taggedValueName, defaultValue )
	GetConnectorTaggedValue = defaultValue

	if not theConnector is nothing and Len(taggedValueName) > 0 then
		dim taggedValue as EA.ConnectorTag
		dim selectedTaggedValue as EA.ConnectorTag
		set selectedTaggedValue = nothing
		'loop omdat TaggedValues.getByName niet werkt bij tagged values van attributen
		for each taggedValue in theConnector.TaggedValues
			if taggedValue.name = taggedValueName then
				set selectedTaggedValue = taggedValue
				exit for
			end if
		next
		if not selectedTaggedValue is nothing then
			GetConnectorTaggedValue = selectedTaggedValue.Value
		end if
	 end if
end function

sub SetElementTaggedValue( theElement, taggedValueName, taggedValueValue )
	if not theElement is nothing and Len(taggedValueName) > 0 then
		dim taggedValue as EA.TaggedValue
		set taggedValue = nothing
		set taggedValue = theElement.TaggedValues.GetByName( taggedValueName )
		if taggedValue is nothing then
			set taggedValue = theElement.TaggedValues.AddNew( taggedValueName, taggedValueValue )
			taggedValue.Update()
		end if
	 end if
end sub

sub SetAttributeTaggedValue( theAttribute, taggedValueName, taggedValueValue )
	if not theAttribute is nothing and Len(taggedValueName) > 0 then
		dim taggedValue as EA.AttributeTag
		dim selectedTaggedValue as EA.AttributeTag
		set selectedTaggedValue = nothing
		'loop omdat TaggedValues.getByName niet werkt bij tagged values van attributen
		for each taggedValue in theAttribute.TaggedValues
			if taggedValue.name = taggedValueName then
				set selectedTaggedValue = taggedValue
				exit for
			end if
		next
		if selectedTaggedValue is nothing then
			set selectedTaggedValue = theAttribute.TaggedValues.AddNew( taggedValueName, taggedValueValue )
			selectedTaggedValue.Update()
		end if
	end if
end sub

sub SetConnectorTaggedValue( theConnector, taggedValueName, taggedValueValue )
	if not theConnector is nothing and Len(taggedValueName) > 0 then
		dim taggedValue as EA.ConnectorTag
		dim selectedTaggedValue as EA.ConnectorTag
		set selectedTaggedValue = nothing
		'loop omdat TaggedValues.getByName niet werkt bij tagged values van attributen
		for each taggedValue in theConnector.TaggedValues
			if taggedValue.name = taggedValueName then
				set selectedTaggedValue = taggedValue
				exit for
			end if
		next
		if selectedTaggedValue is nothing then
			set selectedTaggedValue = theConnector.TaggedValues.AddNew( taggedValueName, taggedValueValue )
			selectedTaggedValue.Update()
		end if
	end if
end sub

sub DeleteElementTaggedValue( theElement, theTagName )
	dim i
	if not theElement is nothing and Len( theTagName ) > 0 then
		dim tags as EA.Collection
		set tags = theElement.TaggedValues
		for i = tags.Count - 1 to 0 step -1
			dim theTag as EA.TaggedValue
			set theTag = tags.GetAt( i )
			if theTag.Name = theTagName then
				call theElement.TaggedValues.DeleteAt( i, FALSE )
			end if
		next
	end if
end sub

sub DeleteAttributeTaggedValue( theAttribute, theTagName )
	dim i
	if not theAttribute is nothing and Len( theTagName ) > 0 then
		dim tags as EA.Collection
		set tags = theAttribute.TaggedValues
		for i = tags.Count - 1 to 0 step -1
			dim theTag as EA.TaggedValue
			set theTag = tags.GetAt( i )
			if theTag.Name = theTagName then
				call theAttribute.TaggedValues.DeleteAt( i, FALSE )
			end if
		next
	end if
end sub

sub DeleteConnectorTaggedValue( theConnector, theTagName )
	dim i
	if not theConnector is nothing and Len( theTagName ) > 0 then
		dim tags as EA.Collection
		set tags = theConnector.TaggedValues
		for i = tags.Count - 1 to 0 step -1
			dim theTag as EA.TaggedValue
			set theTag = tags.GetAt( i )
			if theTag.Name = theTagName then
				call theConnector.TaggedValues.DeleteAt( i, FALSE )
			end if
		next
	end if
end sub

'
' Script Name: GetOrSetOrDeleteGivenTaggedValuesInGivenPackage
' Author: Geert Thijs
' Purpose: To get or set or delete tags with a given name on the elements, attributes or connectors in a given package. Setting means adding the tag if it does not exist,
' if the tag does exist its value is left untouched.
' Date: 19/6/2017
'
sub main
	dim theTagName
	dim theQuery
	dim theElements as EA.Collection
	theTagName = "ap-label-nl"
	theQuery= "select to.object_id FROM t_object to WHERE to.package_id=3"
	set theElements = Repository.GetElementSet( theQuery, 2 )
	dim theElement
	for each theElement in theElements
		if theElement.type="Class" OR theElement.type="Enumeration" OR theElement.type="DataType" then
			'call DeleteElementTaggedValue( theElement, theTagName )
			call SetElementTaggedValue( theElement, theTagName, theElement.Name )
			'MsgBox theElement.Name & " " &  GetElementTaggedValue( theElement, theTagName, "empty" )
			dim theAttributes
			set theAttributes = theElement.Attributes
			dim theAttribute
			for each theAttribute in theAttributes
				'call DeleteAttributeTaggedValue( theAttribute, theTagName )
				call SetAttributeTaggedValue( theAttribute, theTagName, theAttribute.Name )
				'MsgBox theAttribute.Name & " " &  GetAttributeTaggedValue( theAttribute, theTagName, "empty" )
			next
			dim theConnectors
			set theConnectors = theElement.Connectors
			dim theConnector
			for each theConnector in theConnectors
				if theConnector.Type ="Association" OR theConnector.Type ="Aggregation" OR theConnector.Type ="Composition" then
					'call DeleteConnectorTaggedValue( theConnector, theTagName )
					call SetConnectorTaggedValue( theConnector, theTagName, theConnector.Name )
					'MsgBox theConnector.Name & " " &  GetConnectorTaggedValue( theConnector, theTagName, "empty" )
				end if
			next
		end if
   next
end sub

main
	  
