Attribute VB_Name = "TagsAndNotes"
Public Const tagsAndNotesSheetName As String = "TagsAndNotes"

' The pull work starts here
Public Sub PullFromEA()
    Dim eapc As New CEAPackageConnector
    Dim xlsc As New CExcelSheetConnector
    Dim created As CreateEAPackageResult
    Do
        If vbCancel = MsgBox("Please open a model in EA and select in the Project Browser the PACKAGE or the DIAGRAM to pull from. Do not open multiple instances of EA.", vbOKCancel) Then
            Exit Sub
        End If
        created = eapc.Create()
    Loop While created = CREATED_NOTHING
    If created = CREATED_FROM_PACKAGE Then
        If vbYes <> MsgBox("OK to pull notes and tags from PACKAGE '" & eapc.GetPackageName() & "'? This will destoy any previous contents of sheet '" & tagsAndNotesSheetName & "'.", vbYesNo + vbQuestion) Then
            Exit Sub
        End If
    Else
        If vbYes <> MsgBox("OK to pull notes and tags from DIAGRAM '" & eapc.GetDiagramName() & "'? This will destoy any previous contents of sheet '" & tagsAndNotesSheetName & "'.", vbYesNo + vbQuestion) Then
            Exit Sub
        End If
    End If
    Call xlsc.Create(tagsAndNotesSheetName, False, True)
    ' force some wellknown columns
    Call xlsc.AddColumn("(notes)")
    Call xlsc.AddColumn("label-nl")
    Call xlsc.AddColumn("definition-nl")
    Call xlsc.AddColumn("usageNote-nl")
    Call xlsc.AddColumn("uri")
    Call xlsc.AddColumn("ap-label-nl")
    Call xlsc.AddColumn("ap-definition-nl")
    Call xlsc.AddColumn("ap-usageNote-nl")
    Application.Cursor = xlWait
    Application.ScreenUpdating = False
    Call eapc.PullAll(xlsc)
    Call xlsc.ShapeUpSheetAndCloseConnector
    Application.ScreenUpdating = True
    Application.Cursor = xlDefault
    Call MsgBox("Pull complete.", vbInformation)
End Sub

' The push work starts here
Public Sub PushToEA()
    Dim xlsc As New CExcelSheetConnector
    Dim eapc As New CEAPackageConnector
    Dim created As CreateEAPackageResult
    If xlsc.Create(tagsAndNotesSheetName, True, False) = False Then
        Call MsgBox("This workbook does not contain a required sheet named '" & tagsAndNotesSheetName & "', containing the input for this push operation. Nothing Done.", vbCritical)
        Exit Sub
    End If
    Do
        If vbCancel = MsgBox("Please open a model in EA and select in the Project Browser the PACKAGE or DIAGRAM to push to. Do not open multiple instances of EA.", vbOKCancel) Then
            Exit Sub
        End If
        created = eapc.Create()
    Loop While created = CREATED_NOTHING
    If created = CREATED_FROM_PACKAGE Then
        If vbYes <> MsgBox("OK to push notes and tags to PACKAGE '" & eapc.GetPackageName() & "'?", vbYesNo + vbQuestion) Then
            Exit Sub
        End If
    Else
        If vbYes <> MsgBox("OK to push notes and tags to DIAGRAM '" & eapc.GetDiagramName() & "'?", vbYesNo + vbQuestion) Then
            Exit Sub
        End If
    End If
    Application.Cursor = xlWait
    Application.ScreenUpdating = False
    Call eapc.PushAll(xlsc)
    Call xlsc.CloseConnector
    Application.ScreenUpdating = True
    Application.Cursor = xlDefault
    Call MsgBox("Push complete.", vbInformation)
End Sub
