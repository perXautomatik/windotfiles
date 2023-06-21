' MDB_to_CSV.vbs
'
' Converts an Access table to a comma-separated text file.  Requires Microsoft Access.
' Usage:
'  WScript MDB_to_CSV.vbs <input file> <output file>

Option Explicit

' AcTextTransferType
Const acExportDelim = 2
' OpenTextFile iomode
Const ForReading = 1
Const ForAppending = 8

Dim App, FileSys
Set FileSys = CreateObject("Scripting.FileSystemObject")
If FileSys.FileExists(WScript.Arguments(1)) Then
	FileSys.DeleteFile WScript.Arguments(1)
End If
Set App = CreateObject("Access.Application")

On Error Resume Next

Dim I, J, Lines(), Table, TgtFile, TmpFile, TmpFilenames()
App.OpenCurrentDatabase WScript.Arguments(0)
App.Visible = False
If Err = 0 Then
	I = 0
	For Each Table In App.CurrentData.AllTables
		If Left(Table.Name, 4) <> "MSys" Then
			I = I + 1
		End If
	Next
	ReDim TmpFilenames(I - 1)
	Set TgtFile = FileSys.OpenTextFile(WScript.Arguments(1), ForAppending, True)
	I = 0
	For Each Table In App.CurrentData.AllTables
		If Left(Table.Name, 4) <> "MSys" Then
			TgtFile.WriteLine """TABLE " & Table.Name & """"
			TmpFilenames(I) = FileSys.GetSpecialFolder(2) & "\" & FileSys.GetTempName
			App.DoCmd.TransferText acExportDelim, "", Table.Name, TmpFilenames(I)
			Set TmpFile = FileSys.OpenTextFile(TmpFilenames(I), ForReading)
			J = 0
			Do While Not TmpFile.AtEndOfStream
				ReDim Preserve Lines(J)
				Lines(J) = TmpFile.ReadLine
				J = J + 1
			Loop
			TmpFile.Close
			QuickSort 0, UBound(Lines)
			For J = 0 To UBound(Lines)
				TgtFile.WriteLine Lines(J)
			Next
			If I <> UBound(TmpFilenames) Then
				TgtFile.WriteLine
			End If
			I = I + 1
		End If
	Next
	TgtFile.Close
	App.CloseCurrentDatabase
End If

App.Quit

For I = 0 To UBound(TmpFilenames)
	If FileSys.FileExists(TmpFilenames(I)) Then
		FileSys.DeleteFile TmpFilenames(I)
	End If
Next

Sub QuickSort(Lo, Hi)
	Dim I, J, P, T
	Do
		I = Lo
		J = Hi
		P = Int((Lo + Hi) / 2)
		Do
			Do While Lines(P) > Lines(I)
				I = I + 1
			Loop
			Do While Lines(J) > Lines(P)
				J = J - 1
			Loop
			If I > J Then
				Exit Do
			End If
			T = Lines(I)
			Lines(I) = Lines(J)
			Lines(J) = T
			If P = I Then
				P = J
			ElseIf P = J Then
				P = I
			End If
			I = I + 1
			J = J - 1
		Loop While (I <= J)
	If Lo < J Then
		QuickSort Lo, J
	End If
	Lo = I
	If I >= Hi Then
		Exit Do
	End If
	Loop
End Sub