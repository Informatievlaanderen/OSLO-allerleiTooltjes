VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit


Private Sub Workbook_Open()
    ' uncomment next line for debugging
    'Stop
    
    ' dynamically add a toolbar to 'Add-ins' - based on Geert Bellekens' https://bellekens.com/2018/10/12/simple-vba-excel-to-ea-importer-v4-2/
    ' add the toolbar
    Dim myCommandBar As CommandBar
    Dim myCommandBarName As String
    myCommandBarName = "Interact with EA"
    Dim exportTVButton As CommandBarButton
    Dim importGlossaryButton As CommandBarButton
    Dim cmdbar As CommandBar
    For Each cmdbar In Application.CommandBars
        If cmdbar.name = myCommandBarName Then
            Set myCommandBar = cmdbar
        End If
    Next
    If myCommandBar Is Nothing Then
        Set myCommandBar = Application.CommandBars.Add(name:=myCommandBarName, Position:=msoBarFloating, Temporary:=True)
        myCommandBar.Visible = True
        With myCommandBar
            .Left = Application.CommandBars("Standard").Width
            .RowIndex = Application.CommandBars("Standard").RowIndex
            
            Dim walkButton As CommandBarButton
            Set walkButton = .Controls.Add(msoControlButton, , , , True)
            With walkButton
                .Style = msoButtonIconAndCaption
                .Caption = "Walk over content in EA (!!!)"
                .TooltipText = "Walks over EA contents and performs hardcoded actions on it"
                .OnAction = "WalkOverInEA"
            End With
        End With
    End If
End Sub
