VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CExcelSheetConnector"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private sheet As Excel.Worksheet
Private columnKeys As collection
Private rowKeys As collection

' Creates the connector
' Parameters:
'   sheetName: name of a sheet in the current workbook
'   expectExisting: if True and sheet with the given name does not exist: abort
'   deleteExisting: if True and sheet with the given name exists: delete old sheet first
' Return:
'   True means creation successful
Public Function Create(sheetName As String, expectExisting As Boolean, deleteExisting As Boolean) As Boolean
    Create = False
    
    Dim i As Integer
    Dim v As String
    If sheet Is Nothing Then
        On Error Resume Next
        Set sheet = Sheets(sheetName)
        If Err.Number <> 0 Then
            ' sheet does not exist
            Err.Clear
            If expectExisting Then
                Exit Function
            End If
        Else
            ' sheet exists
            If deleteExisting Then
                Application.DisplayAlerts = False
                sheet.Delete
                Application.DisplayAlerts = True
                Set sheet = Nothing
            End If
        End If
        If sheet Is Nothing Then
            Sheets.Add.name = sheetName
            Set sheet = Sheets(sheetName)
            sheet.Rows("1:1").Font.Bold = True
            sheet.Columns("A:A").Font.Bold = True
        End If
        i = 2   'skip column 1
        v = GetCleanStringValue(1, i)
        Set columnKeys = New collection
        While Len(v) > 0
            Call columnKeys.Add(v)
            i = i + 1
            v = GetCleanStringValue(1, i)
        Wend
        i = 2   'skip row 1
        v = GetCleanStringValue(i, 1)
        Set rowKeys = New collection
        While Len(v) > 0
            Call rowKeys.Add(v)
            i = i + 1
            v = GetCleanStringValue(i, 1)
        Wend
        Create = True
    End If
End Function

' Closes the connector
' Parameters:
'  -
Public Sub CloseConnector()
    Set sheet = Nothing
    Set columnKeys = New collection
    Set rowKeys = New collection
End Sub

' Shape up the sheet's visual appearance and close the connector
' Parameters:
'   -
Public Sub ShapeUpSheetAndCloseConnector()
    ' Sort
    sheet.Cells.Select
    sheet.Sort.SortFields.Clear
    sheet.Sort.SortFields.Add2 key:=Range(sheet.Cells(2, 1), sheet.Cells(1 + rowKeys.Count, 1)), _
        SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
    With sheet.Sort
        .SetRange Range(sheet.Cells(1, 1), Cells(1 + rowKeys.Count, 1 + columnKeys.Count))
        .Header = xlYes
        .MatchCase = True
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    
    ' Adapts the width of all columns to its contents
    sheet.Cells.Select
    sheet.Cells.EntireColumn.AutoFit
    
    ' Remove the selection
    sheet.Cells(1, 1).Select
    
    ' And finally close (necessary, our keys are no longer valid after the sorting
    Call CloseConnector
End Sub

' Makes a clean string. Apply to values retrieved from an excel cell or to be put in an excel cell.
' Parameters:
'   x: input value
' Return:
'   String
Private Function CleanString(x) As String
    CleanString = Trim(CStr(x))
End Function

' Gets a clean string from an excel cell.
' Parameters:
'   r: the row index
'   c: the column index
' Return:
'   String
Private Function GetCleanStringValue(r As Integer, c As Integer) As String
    GetCleanStringValue = CleanString(sheet.Cells(r, c))
End Function

' Gets the row index of the row given by a key.
' Parameters:
'   rowKey: the value (key) in column 1 of the row
'   addMissing: if True, add a new row if the key is not found
' Return:
'   Integer
Private Function GetRowIndex(rowKey, Optional addMissing As Boolean = True) As Integer
    GetRowIndex = 0
    
    Dim k As String
    Dim i As Integer
    Dim v As Variant
    k = CleanString(rowKey)
    i = 2   'skip row 1
    For Each v In rowKeys
        If v = k Then
            GetRowIndex = i
            Exit For
        End If
        i = i + 1
    Next
    If GetRowIndex = 0 And addMissing Then
        Call rowKeys.Add(k)
        sheet.Cells(i, 1) = k
        GetRowIndex = i
    End If
End Function

' Gets the column index of the column given by a key.
' Parameters:
'   columnKey: the value (key) in row 1 of the column
'   addMissing: if True, add a new column if the key is not found
' Return:
'   Integer
Private Function GetColumnIndex(columnKey, Optional addMissing As Boolean = True) As Integer
    GetColumnIndex = 0
    
    Dim k As String
    Dim i As Integer
    Dim v As Variant
    k = CleanString(columnKey)
    i = 2   'skip column 1
    For Each v In columnKeys
        If v = k Then
            GetColumnIndex = i
            Exit For
        End If
        i = i + 1
    Next
    If GetColumnIndex = 0 And addMissing Then
        Call columnKeys.Add(k)
        sheet.Cells(1, i) = k
        GetColumnIndex = i
    End If
End Function

' Adds a row with a given key, if there is not such row yet.
' Parameters:
'   rowKey: the value (key) in column 1 of the row
Public Sub AddRow(rowKey)
    Dim i As Integer
    i = GetRowIndex(rowKey)
End Sub

' Adds a column with a given key, if there is not such column yet.
' Parameters:
'   columnKey: the value (key) in row 1 of the column
Public Sub AddColumn(columnKey)
    Dim i As Integer
    i = GetColumnIndex(columnKey)
End Sub

' Sets a cleaned value in a cell, given by its row and column keys.
' Parameters:
'   rowKey: the value (key) in column 1 of the row
'   columnKey: the value (key) in row 1 of the column
'   value: the value to be cleaned and written in the cell
Public Sub SetStringValue(rowKey, columnKey, value)
    sheet.Cells(GetRowIndex(rowKey), GetColumnIndex(columnKey)).value = CleanString(value)
End Sub

' Gets a cleaned value from a cell, given by its row and column keys.
' Parameters:
'   rowKey: the value (key) in column 1 of the row
'   columnKey: the value (key) in row 1 of the column
'   defaultValue: the value to be returned if the cell does not exist
' Returns:
'   String
Public Function GetStringValue(rowKey, columnKey, Optional defaultValue As String = "") As String
    On Error Resume Next
    GetStringValue = CleanString(sheet.Cells(GetRowIndex(rowKey, False), GetColumnIndex(columnKey, False)).value)
    If Err.Number <> 0 Then
        Err.Clear
        GetStringValue = defaultValue
    End If
End Function

' Sets a list of cleaned values in a row, given by its row key.
' The row is added, if it didn't exist yet.
' Parameters:
'   rowKey: the value (key) in column 1 of the row
'   keyValues: collection of CKeyValue objects, where each key is a column key and each value is the value to be cleaned and written
Public Sub SetStringValues(rowKey, keyValues As collection)
    Dim r As Integer
    Dim kv As CKeyValue
    r = GetRowIndex(rowKey)
    For Each kv In keyValues
        sheet.Cells(r, GetColumnIndex(kv.key)).value = CleanString(kv.value)
    Next
End Sub

' Gets a list of cleaned values from a row, given by its row key.
' Parameters:
'   rowKey: the value (key) in column 1 of the row
' Returns:
'   Collection of CKeyValue objects, where each key is a column key and each value is the cleaned value read.
'   For rows not found, the collection is empty.
Public Function GetStringValues(rowKey) As collection
    Set GetStringValues = New collection
    
    Dim r As Integer
    Dim columnKey As Variant
    Dim kv As CKeyValue
    r = GetRowIndex(rowKey, False)
    If r > 0 Then
        For Each columnKey In columnKeys
            Set kv = New CKeyValue
            kv.key = columnKey
            kv.value = CleanString(sheet.Cells(r, GetColumnIndex(columnKey, False)).value)
            Call GetStringValues.Add(kv)
        Next
    End If
End Function

