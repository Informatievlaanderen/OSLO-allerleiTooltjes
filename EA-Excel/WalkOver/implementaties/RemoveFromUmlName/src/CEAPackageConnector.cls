VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CEAPackageConnector"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' This is a stripped version of the module with the same name, found in TagsAndNotes,
' Extended with the method WalkOverAll() and its submethods Do...()

Option Explicit

Private app As EA.app
Private repo As EA.Repository
Private package As EA.package
Private diagram As EA.diagram
Private elements As EA.collection
Private packageNames As Scripting.Dictionary

Private Const longTagWorkaround As String = "NOTE"
Private Const semiTagNameForNotes As String = "(notes)"
Private Const specialValueDeleteCommand As String = "d!"

Public Enum CreateEAPackageResult
CREATED_NOTHING
CREATED_FROM_PACKAGE
CREATED_FROM_DIAGRAM
End Enum



' Creates the Enterprise Architect package connector
' Parameters:
'   -
' Return:
'   CreateEAPackageResult
Public Function Create() As CreateEAPackageResult
    Create = CREATED_NOTHING
    
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
                Dim query
                ' Kijk na of een diagram geselecteerd is
                Dim selectedObject
                Set selectedObject = repo.GetTreeSelectedObject()
                If selectedObject.ObjectType = EA.otDiagram Then
                    ' query voor alle elementen die op het diagram staan
                    Set diagram = selectedObject
                    query = "select to.object_id from (t_diagramobjects inner join t_diagram on t_diagramobjects.diagram_id = t_diagram.diagram_id) inner join t_object as to on to.object_id = t_diagramobjects.object_id where t_diagram.diagram_id=" & diagram.DiagramID
                    Create = CREATED_FROM_DIAGRAM
                Else
                    ' query voor alle elementen die in het package zitten
                    query = "select to.object_id FROM t_object to WHERE to.package_id=" & package.packageID
                    Create = CREATED_FROM_PACKAGE
                End If
                ' Haal deze alle op
                Set elements = repo.GetElementSet(query, 2)
                ' Een cache voor package namen
                Set packageNames = CreateObject("Scripting.Dictionary")
                Call packageNames.Add(CStr(package.packageID), package.name)
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

' Gets the name of the selected diagram in the selected package
' Parameters:
'   -
' Returns:
'   String; "" if no diagram is selected
Public Function GetDiagramName() As String
    GetDiagramName = ""
    
    If Not diagram Is Nothing Then
        GetDiagramName = diagram.name
    End If
End Function

' Call this method before modifying the EA model. It increases speed.
' Parameters:
'   -
Private Sub DisableUI()
    repo.EnableUIUpdates = False
End Sub

' Call this method when finished modifying the EA model. It updates the UI and positions the project browser on the initially selected item.
' Parameters:
'   -
Private Sub EnableUI()
    If Not diagram Is Nothing Then
        Call repo.RefreshModelView(0)
        Call repo.ShowInProjectView(diagram)
    Else
        Call repo.RefreshModelView(package.packageID)
        Call repo.ShowInProjectView(package)
    End If
    repo.EnableUIUpdates = True
End Sub


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

' Gets notes and tags from one owner.
' Parameters:
'   owner: object owning the notes and tags. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
' Return:
'   Collection of CKeyValue objects
'   - key: "(notes)" for notes, else the tag name
'   - value: notes, tag value
Private Function GetTagsAndNotesFromOwner(owner) As collection
    Set GetTagsAndNotesFromOwner = New collection

    Dim kv As CKeyValue
    Dim tv
    Set kv = New CKeyValue
    kv.key = semiTagNameForNotes
    kv.value = GetNotesValue(owner)
    Call GetTagsAndNotesFromOwner.Add(kv)
    For Each tv In owner.TaggedValues
        Set kv = New CKeyValue
        If owner.ObjectType = EA.otConnectorEnd Then
            kv.key = tv.Tag
        Else
            kv.key = tv.name
        End If
        kv.value = GetTagValue(owner, kv.key)
        Call GetTagsAndNotesFromOwner.Add(kv)
    Next
End Function

' Sets notes and tags in one owner.
' Empty values are not pushed (i.e. contents in EA kept as is).
' Special value 'delete' will result in notes being cleared or tag being deleted.
' Parameters:
'   owner: object owning the notes and tags. Possible types: EA.Element, EA.Attribute, EA.Connector, EA.ConnectorEnd
'   coll: Collection of CKeyValue objects
'     - key: "(notes)" for notes, else the tag name
'     - value: notes, tag value
Private Sub SetTagsAndNotesInOwner(owner, coll As collection)
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

' Does an operation on an element
' (See code for what is done in this case...)
' Parameters:
'   elem: the element to work on
Private Sub DoElement(elem As EA.Element)
    ' Remove a trailing string from the UML name (dependent on metatype)
    Dim search, orig, modified As String
    Select Case LCase(elem.MetaType)
    Case "datatype"
        search = "Datatype"
    Case "enumeration"
        search = "Enumeratie"
    Case Else
        search = "Klasse"
    End Select
    orig = elem.name
    If Right(orig, Len(search)) = search Then
        modified = Left(orig, Len(orig) - Len(search))
        Debug.Print (IdentifyingString(Array(elem)) & ": " & orig & " --> " & modified)
        elem.name = modified
        elem.Update
    End If
End Sub

' Does an operation on an attribute
' (See code for what is done in this case...)
' Parameters:
'   elem: the element to which the element belongs
'   att: the attribute to work on
Private Sub DoAttribute(elem As EA.Element, att As EA.Attribute)
    ' Remove a trailing string from the UML name
    Dim search, orig, modified As String
    search = "Attribuut"
    orig = att.name
    If Right(orig, Len(search)) = search Then
        modified = Left(orig, Len(orig) - Len(search))
        Debug.Print (IdentifyingString(Array(elem, att)) & ": " & orig & " --> " & modified)
        att.name = modified
        att.Update
    End If
End Sub

' Does an operation on an connector
' (See code for what is done in this case...)
' Parameters:
'   sourceElem: the element at the source side of the connector
'   conn: the connector to work on
'   targetElem: the element at the target side of the connector
Private Sub DoConnector(sourceElem As EA.Element, conn As EA.connector, targetElem As EA.Element)
    If Len(conn.name) > 0 Then
        ' Remove a trailing string from the UML name
        Dim search, orig, modified As String
        search = "Associatie"
        orig = conn.name
        If Right(orig, Len(search)) = search Then
            modified = Left(orig, Len(orig) - Len(search))
            Debug.Print (IdentifyingString(Array(sourceElem, conn, targetElem)) & ": " & orig & " --> " & modified)
            conn.name = modified
            conn.Update
        End If
    End If
End Sub

' Does an operation on an connector end
' (See code for what is done in this case...)
' Parameters:
'   elem: the element at this side of the connector
'   connOtherEnd: the connector end at the other side of the connector
'   otherElem: the element at the other side of the connector
Private Sub DoConnectorEnd(elem As EA.Element, otherConnEnd As EA.ConnectorEnd, otherElem As EA.Element)
    If Len(otherConnEnd.Role) > 0 Then
        ' Remove a trailing string from the UML name of the role
        Dim search, orig, modified As String
        search = "Rol"
        orig = otherConnEnd.Role
        If Right(orig, Len(search)) = search Then
            modified = Left(orig, Len(orig) - Len(search))
            Debug.Print (IdentifyingString(Array(elem, otherConnEnd, otherElem)) & ": " & orig & " --> " & modified)
            otherConnEnd.Role = modified
            otherConnEnd.Update
        End If
    End If
End Sub

' Walk over all elements, attributes, connectors and connector ends (roles) and execute hardcoded operations on them.
' The hardcoded operation are implemented in the Do... subs above
Public Sub WalkOverAll()
    Dim elem As EA.Element
    Dim attributes As EA.collection
    Dim att As EA.Attribute
    Dim connectors As EA.collection
    Dim conn As EA.connector
    Dim handledConnectors As Scripting.Dictionary 'Use this in stead of a set, which doesn't exist in VBA
    Set handledConnectors = CreateObject("Scripting.Dictionary")
    Dim sourceElem As EA.Element
    Dim targetElem As EA.Element
    Call DisableUI
    For Each elem In elements
        If elem.Type = "Class" Or elem.Type = "Enumeration" Or elem.Type = "DataType" Then
            Call DoElement(elem)
            Set attributes = elem.attributes
            For Each att In attributes
                Call DoAttribute(elem, att)
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
                        ' Handle the connector
                        Call DoConnector(sourceElem, conn, targetElem)
                        ' Handle the role at the target side
                        Call DoConnectorEnd(sourceElem, conn.SupplierEnd, targetElem)
                        ' Handle the role at the source side
                        Call DoConnectorEnd(targetElem, conn.ClientEnd, sourceElem)
                    End If
                End If
            Next
        End If
   Next
   Call EnableUI
End Sub

