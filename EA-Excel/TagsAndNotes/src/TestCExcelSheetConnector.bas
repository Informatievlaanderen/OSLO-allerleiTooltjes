Attribute VB_Name = "TestCExcelSheetConnector"
Public Sub TestExcelSheetConnector()
    Const sheetName As String = "TestXLSC"
    Dim xlsc As New CExcelSheetConnector
    Dim i As Integer
    Dim j As Integer
    Dim coll As Collection
    Dim kv As Variant
    
    ' delete existing if any
    Debug.Assert xlsc.Create(sheetName, False, True) = True
    xlsc.CloseConnector
    ' expect existing, but do not delete existing
    Debug.Assert xlsc.Create(sheetName, True, False) = True
    xlsc.CloseConnector
    ' do not delete existing
    Debug.Assert xlsc.Create(sheetName, False, False) = True
    
    ' simple operations
    Debug.Assert xlsc.GetStringValue("r1", "c1") = ""
    Call xlsc.SetStringValue("r1", "c1", "r1c1")
    Debug.Assert xlsc.GetStringValue("r1", "c1") = "r1c1"
    Debug.Assert xlsc.GetStringValue("r9", "c9") = ""
    
    ' creation without closing should fail (but we continue with previous)
    Debug.Assert xlsc.Create(sheetName, False, True) = False
    Debug.Assert xlsc.GetStringValue("r1", "c1") = "r1c1"
    
    xlsc.CloseConnector
    ' expect existing, delete existing
    Debug.Assert xlsc.Create(sheetName, True, True) = True
    Debug.Assert xlsc.GetStringValue("r1", "c1") = ""
    
    ' add 4 rows
    For i = 1 To 4
        Call xlsc.AddRow(" r" & i & " ")
    Next
    ' add 5 columns
    For j = 1 To 4
        Call xlsc.AddColumn(" c" & j & " ")
    Next
    ' fill 25 values (remark: should add 1 row and 1 column automatically)
    For i = 1 To 5
        For j = 1 To 5
            Call xlsc.SetStringValue("r" & i, "c" & j, "r" & i & "c" & j)
        Next
    Next
    ' check 25 values
    For i = 1 To 5
        For j = 1 To 5
            Debug.Assert xlsc.GetStringValue("r" & i, "c" & j) = "r" & i & "c" & j
        Next
    Next
    ' check not existing row, column keys
    Debug.Assert xlsc.GetStringValue("bad row key", "c1") = ""
    Debug.Assert xlsc.GetStringValue("r1", "bad column key") = ""
    Debug.Assert xlsc.GetStringValue("bad row key", "c1", "default value") = "default value"
    Debug.Assert xlsc.GetStringValue("r1", "bad column key", "default value") = "default value"
    ' check 5 collections of 5 values
    For i = 1 To 5
        Set coll = xlsc.GetStringValues("r" & i)
        Debug.Assert coll.Count = 5
        j = 1
        For Each kv In coll
            Debug.Assert kv.key = "c" & j
            Debug.Assert kv.value = "r" & i & "c" & j
            j = j + 1
        Next
    Next
    ' fill 6 values in a new 6th row (remark: should add 1 row and 1 column automatically)
    Set coll = New Collection
    i = 6
    For j = 1 To 6
        Set kv = New CKeyValue
        kv.key = "c" & j
        kv.value = "r" & i & "c" & j
        Call coll.Add(kv)
    Next
    Call xlsc.SetStringValues("r" & i, coll)
    ' check 6 values
    For j = 1 To 6
        Debug.Assert xlsc.GetStringValue("r" & i, "c" & j) = "r" & i & "c" & j
    Next
    ' check not existing row
    Debug.Assert xlsc.GetStringValues("bad row key").Count = 0

End Sub


