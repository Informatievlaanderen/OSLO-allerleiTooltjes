Attribute VB_Name = "Main"
' The work starts here
Public Sub WalkOverInEA()
    Dim eapc As New CEAPackageConnector
    Dim created As CreateEAPackageResult
    Do
        If vbCancel = MsgBox("Please open a model in EA and select in the Project Browser the PACKAGE or the DIAGRAM to be worked on. Do not open multiple instances of EA.", vbOKCancel) Then
            Exit Sub
        End If
        created = eapc.Create()
    Loop While created = CREATED_NOTHING
    If created = CREATED_FROM_PACKAGE Then
        If vbYes <> MsgBox("OK to work on PACKAGE '" & eapc.GetPackageName() & "'?", vbYesNo + vbQuestion) Then
            Exit Sub
        End If
    Else
        If vbYes <> MsgBox("OK to work on DIAGRAM '" & eapc.GetDiagramName() & "'?", vbYesNo + vbQuestion) Then
            Exit Sub
        End If
    End If
    Application.Cursor = xlWait
    Call eapc.WalkOverAll
    Application.Cursor = xlDefault
    Call MsgBox("Work complete.", vbInformation)
End Sub

