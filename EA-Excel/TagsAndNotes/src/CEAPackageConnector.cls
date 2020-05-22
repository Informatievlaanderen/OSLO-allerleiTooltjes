VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CEAPackageConnector"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private app As EA.app
Private repo As EA.Repository
Private package As EA.package
Private elements As EA.collection
Private packageNames As Scripting.Dictionary

Private Const longTagWorkaround As String = "NOTE"
Private Const semiTagNameForNotes As String = "(notes)"
Private Const specialValueDeleteCommand As String = "d!"


' Creates the Enterprise Architect package connector
' Parameters:
'   -
' Return:
'   True means creation successful
Public Function Create() As Boolean
    Create = False
    
    Set app = Nothing
    Set repo = Nothing
    Set package = Nothing
    Set elements = Nothing
    Set app = GetObject(, "EA.app")
    If Not app Is Nothing Then
        Set repo = app.Repository
        If Not repo Is Nothing Then
            Set package = repo.GetTreeSelectedPackage()
            If Not package Is Nothing Then
                ' Haal alle elementen op uit het package
                Dim query
                query = "select to.object_id FROM t_object to WHERE to.package_id=" & package.packageID
                Set elements = repo.GetElementSet(query, 2)
                Set packageNames = CreateObject("Scripting.Dictionary")
                Call packageNames.Add(CStr(package.packageID), package.name)
                Create = True
            End If
        End If
    End If
End Function

' Gets the name of the selected package
' Parameters:
'   -
' Returns:
'   String
Public Function GetPackageName() As String
    GetPackageName = package.name
End Function

' Gets a tag object
' Parameters:
'   owner: object owning the tag. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: name of the tag
' Return:
'   corresponderend object, possible types: EA.TaggedValue, EA.AttributeTag, EA.ConnectorTag, EA.RoleTag
Private Function GetTag(owner, name As String)
    Set GetTag = Nothing
    
    Dim rt As EA.RoleTag
    Dim tv
    If Not owner Is Nothing And Len(name) > 0 Then
        ' remark: owner.TaggedValues.GetByName(name) seems not stable, so avoided
        If owner.ObjectType = EA.otConnectorEnd Then
            For Each rt In owner.TaggedValues
                If rt.Tag = name Then
                    Set GetTag = rt
                    Exit For
                End If
            Next
        Else
            For Each tv In owner.TaggedValues
                If tv.name = name Then
                    Set GetTag = tv
                    Exit For
                End If
            Next
        End If
    End If
End Function

' Gets a tag value
' Parameters:
'   owner: object owning the tag. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: name of the tag
'   defaultValue: value to return if the tag does not exist
' Return:
'   String
Private Function GetTagValue(owner, name As String, Optional defaultValue As String = "") As String
    GetTagValue = defaultValue
    
    Dim tv
    Set tv = GetTag(owner, name)
    If Not tv Is Nothing Then
        ' Remark that the trick with NOTE does not work for rolles, because RoleTag.Notes is not defined in EA's API.
        ' But this seems not needed anyway; apparently a RoleTag.value supports strings longer than255 karakters (tested with 512)
        If tv.value = longTagWorkaround And owner.ObjectType <> otConnectorEnd Then
            GetTagValue = tv.Notes
        Else
            GetTagValue = tv.value
        End If
    End If
End Function

' Sets a tag value
' Parameters:
'   owner: object owning the tag. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: name of the tag
'   value: value for the tag
'   overwrite: if False, existing tag values won't be overwritten
Private Sub SetTagValue(owner, name As String, value As String, Optional overwrite As Boolean = True)
    Dim tv
    Set tv = GetTag(owner, name)
    If tv Is Nothing Then
        ' Same remark about the trick with NOTE as in GetTagValue
        If Len(value) > 255 And owner.ObjectType <> otConnectorEnd Then
            Set tv = owner.TaggedValues.AddNew(name, longTagWorkaround)
            tv.Notes = value
        Else
            Set tv = owner.TaggedValues.AddNew(name, value)
        End If
        Call tv.Update
        Call owner.TaggedValues.Refresh
    Else
        If Not overwrite Then
            Exit Sub
        End If
        ' Same remark about the trick with NOTE as in GetTagValue
        If Len(value) > 255 And owner.ObjectType <> otConnectorEnd Then
            tv.value = longTagWorkaround
            tv.Notes = value
        Else
            tv.value = value
        End If
        Call tv.Update
        Call owner.TaggedValues.Refresh
    End If
End Sub

' Deletes a tag object.
' If multiple tags with the given name exist for the given owner, deletes them all.
' Parameters:
'   owner: object owning the tag. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   name: name of the tag
Private Sub DeleteTag(owner, name As String)
    If Not owner Is Nothing And Len(name) > 0 Then
        Dim tvs As EA.collection
        Set tvs = owner.TaggedValues
        Dim i, tv
        If owner.ObjectType = EA.otConnectorEnd Then
            For i = tvs.Count - 1 To 0 Step -1
                Set tv = tvs.GetAt(i)
                If tv.Tag = name Then
                    Call owner.TaggedValues.DeleteAt(i, False)
                End If
            Next
        Else
            For i = tvs.Count - 1 To 0 Step -1
                Set tv = tvs.GetAt(i)
                If tv.name = name Then
                    Call owner.TaggedValues.DeleteAt(i, False)
                End If
            Next
        End If
        Call owner.TaggedValues.Refresh
    End If
End Sub

' Gets a notes value
' Parameters:
'   owner: object owning the tag. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   defaultValue: value to return if the tag does not exist
' Return:
'   String
Private Function GetNotesValue(owner, Optional defaultValue As String = "") As String
    GetNotesValue = defaultValue
    
    If Not owner Is Nothing Then
        Select Case owner.ObjectType
        Case EA.otElement, EA.otAttribute, EA.otConnector
            GetNotesValue = owner.Notes
        Case EA.otConnectorEnd
            GetNotesValue = owner.RoleNote
        End Select
    End If
End Function

' Sets a notes value
' Parameters:
'   owner: object owning the notes. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   value: value for the tag
'   overwrite: if False, non-empty notes won't be overwritten
Private Sub SetNotesValue(owner, value As String, Optional overwrite As Boolean = True)
    If Not owner Is Nothing Then
        If owner.ObjectType = EA.otConnectorEnd Then
            If overwrite Or Len(owner.RoleNote) = 0 Then
                owner.RoleNote = value
                Call owner.Update
            End If
        Else
            If overwrite Or Len(owner.Notes) = 0 Then
                owner.Notes = value
                Call owner.Update
            End If
        End If
    End If
End Sub

' Makes an identifying string for an object in a hierarchy.
' The identifying string consists of different parts, constructed from the names in the hierarchy.
' The different parts are separated by a "|".
' Each part is prefixed by a letter followed by a "=". Prefix letters:
'   k for classes
'   d for datatypes
'   e for enumerations
'   a for attributs
'   c for connectors
'   r for roles (aka connector ends with a non-empty name)
' Parameters:
'   hierarchy: array of objects containing one or more entries. Possible types:
'     EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
Private Function IdentifyingString(hierarchy) As String
    IdentifyingString = ""
    
    Dim obj
    Dim packageName As String
    For Each obj In hierarchy
        If IdentifyingString <> "" Then
            IdentifyingString = IdentifyingString & "|"
        End If
        Select Case obj.ObjectType
        Case EA.otElement
            packageName = packageNames(CStr(obj.packageID))
            If packageName = "" Then
                packageName = repo.GetPackageByID(obj.packageID).name
                packageNames(CStr(obj.packageID)) = packageName
            End If
            Select Case LCase(obj.MetaType)
            Case "datatype"
                IdentifyingString = IdentifyingString & "d=" & packageName & "::" & obj.name
            Case "enumeration"
                IdentifyingString = IdentifyingString & "e=" & packageName & "::" & obj.name
            Case Else
                IdentifyingString = IdentifyingString & "k=" & packageName & "::" & obj.name
            End Select
        Case EA.otAttribute
            IdentifyingString = IdentifyingString & "a=" & obj.name
        Case EA.otConnector
            IdentifyingString = IdentifyingString & "c=" & obj.name
        Case EA.otConnectorEnd
            IdentifyingString = IdentifyingString & "r=" & obj.Role
        End Select
    Next
End Function

' Makes an augmented value.
' The augmentation consists of a substitution of {...} fields in the input value.
' Parameters:
'   value: value for the tag, optionnally including one or more {...} fields, that will be substituted as follows:
'     - {name}: will be replaced by the UML name of the owning object
'     - {name-to-label}: will be replaced by a transformation of the UML name of the owning object, suitable for label tags:
'       - a leading caret symbool is removed from the UML name
'       - the UML name is split into space separated words
'         - the word boundary is:
'           - between a lowercase letter and a following uppercase letter or digit
'           - or between a digit and a following letter
'         - the first letter of each word is:
'           - uppercase for classes, datatypes and enumerations
'           - lowercase for other owning objects
'   owner: object owning the tag. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
' Return:
'   String
Private Function AugmentedValue(value As String, owner) As String
    AugmentedValue = value

    Dim umlName As String
    Dim firstUpper As Boolean
    Select Case owner.ObjectType
    Case EA.otElement
        umlName = owner.name
        firstUpper = True
    Case EA.otAttribute
        umlName = owner.name
        firstUpper = False
    Case EA.otConnector
        umlName = owner.name
        firstUpper = False
    Case EA.otConnectorEnd
        umlName = owner.Role
        firstUpper = False
    End Select
    If InStr(value, "{name}") Then
        AugmentedValue = Replace(value, "{name}", umlName)
    End If
    If InStr(value, "{name-to-label}") Then
        Dim newName
        newName = ""
        If Len(umlName) > 0 Then
            Dim i0, cPrevious, i, c, newWord
            ' remove leading caret if any
            If Mid(umlName, 1, 1) = "^" Then
                i0 = 2
            Else
                i0 = 1
            End If
            ' first char
            cPrevious = Mid(umlName, i0, 1)
            If firstUpper Then
                newName = newName & UCase(cPrevious)
            Else
                newName = newName & LCase(cPrevious)
            End If
            ' next chars
            For i = i0 + 1 To Len(umlName)
                c = Mid(umlName, i, 1)
                newWord = False
                If IsNumeric(cPrevious) Then
                    If Not IsNumeric(c) Then
                        newWord = True
                    End If
                Else
                    If cPrevious = LCase(cPrevious) Then
                        If IsNumeric(c) Or c = UCase(c) Then
                            newWord = True
                        End If
                    End If
                End If
                If newWord Then
                    If firstUpper Then
                        newName = newName & " " & UCase(c)
                    Else
                        newName = newName & " " & LCase(c)
                    End If
                Else
                    newName = newName & c
                End If
                cPrevious = c
            Next
        End If
        AugmentedValue = Replace(value, "{name-to-label}", newName)
    End If
End Function

' Pulls notes and tags from one owner.
' Parameters:
'   owner: object owning the notes and tags. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
' Return:
'   Collection of CKeyValue objects
'   - key: "(notes)" for notes, else the tag name
'   - value: notes, tag value
Private Function PullOneOwner(owner) As collection
    Set PullOneOwner = New collection

    Dim kv As CKeyValue
    Dim tv
    Set kv = New CKeyValue
    kv.key = semiTagNameForNotes
    kv.value = GetNotesValue(owner)
    Call PullOneOwner.Add(kv)
    For Each tv In owner.TaggedValues
        Set kv = New CKeyValue
        If owner.ObjectType = EA.otConnectorEnd Then
            kv.key = tv.Tag
        Else
            kv.key = tv.name
        End If
        kv.value = GetTagValue(owner, kv.key)
        Call PullOneOwner.Add(kv)
    Next
End Function

' Pushes notes and tags to one owner.
' Empty values are not pushed (i.e. contents in EA kept as is).
' Special value 'delete' will result in notes being cleared or tag being deleted.
' Parameters:
'   owner: object owning the notes and tags. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   coll: Collection of CKeyValue objects
'     - key: "(notes)" for notes, else the tag name
'     - value: notes, tag value
Private Sub PushOneOwner(owner, coll As collection)
    Dim kv As CKeyValue
    For Each kv In coll
        If Len(kv.value) > 0 Then
            If kv.key = semiTagNameForNotes Then
                If kv.value = specialValueDeleteCommand Then
                    Call SetNotesValue(owner, "")
                Else
                    Call SetNotesValue(owner, AugmentedValue(kv.value, owner))
                End If
            Else
                If kv.value = specialValueDeleteCommand Then
                    Call DeleteTag(owner, kv.key)
                Else
                    Call SetTagValue(owner, kv.key, AugmentedValue(kv.value, owner))
                End If
            End If
        End If
    Next
End Sub

' Pulls notes and tags from all elements, attributes, connectors and connector ends (roles).
' Parameters:
'   xlsc: Excel sheet connector where the pulled results must be written to
Public Sub PullAll(xlsc As CExcelSheetConnector)
    Dim elem As EA.element
    Dim attributes As EA.collection
    Dim att As EA.Attribute
    Dim connectors As EA.collection
    Dim conn As EA.connector
    Dim handledConnectors As Scripting.Dictionary 'Use this in stead of a set, which doesn't exist in VBA
    Set handledConnectors = CreateObject("Scripting.Dictionary")
    Dim sourceElem As EA.element
    Dim targetElem As EA.element
    For Each elem In elements
        If elem.Type = "Class" Or elem.Type = "Enumeration" Or elem.Type = "DataType" Then
            Call xlsc.SetStringValues(IdentifyingString(Array(elem)), PullOneOwner(elem))
            Set attributes = elem.attributes
            For Each att In attributes
                Call xlsc.SetStringValues(IdentifyingString(Array(elem, att)), PullOneOwner(att))
            Next
            Set connectors = elem.connectors
            For Each conn In connectors
                If conn.Type = "Association" Or conn.Type = "Aggregation" Or conn.Type = "Composition" Then
                    ' If both connector ends connect to elements of the same package, they will appear twice here; handle only one
                    If Not handledConnectors.Exists(CStr(conn.ConnectorID)) Then
                        Call handledConnectors.Add(CStr(conn.ConnectorID), "")
                        If conn.ClientID = elem.ElementID Then
                            Set sourceElem = elem
                            Set targetElem = repo.GetElementByID(conn.SupplierID)
                        Else
                            Set sourceElem = repo.GetElementByID(conn.ClientID)
                            Set targetElem = elem
                        End If
                        ' Handle the connector (unless if it's nameless)
                        If Len(conn.name) > 0 Then
                            Call xlsc.SetStringValues(IdentifyingString(Array(sourceElem, conn, targetElem)), PullOneOwner(conn))
                        End If
                        ' Handle the role at the target side (unless if it's nameless)
                        If Len(conn.SupplierEnd.Role) > 0 Then
                            Call xlsc.SetStringValues(IdentifyingString(Array(sourceElem, conn.SupplierEnd, targetElem)), PullOneOwner(conn.SupplierEnd))
                        End If
                        ' Handle the role at the source side (unless if it's nameless)
                        If Len(conn.ClientEnd.Role) > 0 Then
                            Call xlsc.SetStringValues(IdentifyingString(Array(targetElem, conn.ClientEnd, sourceElem)), PullOneOwner(conn.ClientEnd))
                        End If
                    End If
                End If
            Next
        End If
   Next
End Sub


' Pushes notes and tags to all elements, attributes, connectors and connector ends (roles).
' Parameters:
'   xlsc: Excel sheet connector where the input to be pushed must be read from
Public Sub PushAll(xlsc As CExcelSheetConnector)
    Dim elem As EA.element
    Dim attributes As EA.collection
    Dim att As EA.Attribute
    Dim connectors As EA.collection
    Dim conn As EA.connector
    Dim handledConnectors As Scripting.Dictionary 'Use this in stead of a set, which doesn't exist in VBA
    Set handledConnectors = CreateObject("Scripting.Dictionary")
    Dim sourceElem As EA.element
    Dim targetElem As EA.element
    For Each elem In elements
        If elem.Type = "Class" Or elem.Type = "Enumeration" Or elem.Type = "DataType" Then
            Call PushOneOwner(elem, xlsc.GetStringValues(IdentifyingString(Array(elem))))
            Set attributes = elem.attributes
            For Each att In attributes
                Call PushOneOwner(att, xlsc.GetStringValues(IdentifyingString(Array(elem, att))))
            Next
            Set connectors = elem.connectors
            For Each conn In connectors
                If conn.Type = "Association" Or conn.Type = "Aggregation" Or conn.Type = "Composition" Then
                    ' If both connector ends connect to elements of the same package, they will appear twice here; handle only one
                    If Not handledConnectors.Exists(CStr(conn.ConnectorID)) Then
                        Call handledConnectors.Add(CStr(conn.ConnectorID), "")
                        If conn.ClientID = elem.ElementID Then
                            Set sourceElem = elem
                            Set targetElem = repo.GetElementByID(conn.SupplierID)
                        Else
                            Set sourceElem = repo.GetElementByID(conn.ClientID)
                            Set targetElem = elem
                        End If
                        ' Handle the connector (unless if it's nameless)
                        If Len(conn.name) > 0 Then
                            Call PushOneOwner(conn, xlsc.GetStringValues(IdentifyingString(Array(sourceElem, conn, targetElem))))
                        End If
                        ' Handle the role at the target side (unless if it's nameless)
                        If Len(conn.SupplierEnd.Role) > 0 Then
                            Call PushOneOwner(conn.SupplierEnd, xlsc.GetStringValues(IdentifyingString(Array(sourceElem, conn.SupplierEnd, targetElem))))
                        End If
                        ' Handle the role at the source side (unless if it's nameless)
                        If Len(conn.ClientEnd.Role) > 0 Then
                            Call PushOneOwner(conn.ClientEnd, xlsc.GetStringValues(IdentifyingString(Array(targetElem, conn.ClientEnd, sourceElem))))
                        End If
                    End If
                End If
            Next
        End If
   Next
End Sub

