' INI_sorted.vbs
'
' Sorts .INI files.
' Usage:
'  WScript INI_sorted.vbs <input file> <output file>
'
' Notes:
'  Handles Unicode or ASCII encodings
'  Handles line continuations ('\' at end of line)
'  Blank grouped with next
'  Comment grouped with previous

Option Explicit

' OpenTextFile format
Const TristateTrue = -1
Const TristateFalse = 0
' OpenTextFile iomode
Const ForReading = 1

Dim FileSys
Set FileSys = CreateObject("Scripting.FileSystemObject")
If FileSys.FileExists(WScript.Arguments(1)) Then
	FileSys.DeleteFile WScript.Arguments(1)
End If
' Calculate codepage (Unicode or ASCII)
Dim CodePage, SrcFile
Set SrcFile = FileSys.OpenTextFile(WScript.Arguments(0), ForReading, False, TristateFalse)
If Left(SrcFile.ReadLine, 2) = Chr(255) & Chr(254) Then
	CodePage = TristateTrue
Else
	CodePage = TristateFalse
End If
SrcFile.Close
' Load lines
Dim BOM, HasBOM, I, Lines()
BOM = Chr(239) & Chr(187) & Chr(191)
HasBOM = 0
Set SrcFile = FileSys.OpenTextFile(WScript.Arguments(0), ForReading, False, CodePage)
I = 0
Do While Not SrcFile.AtEndOfStream
	ReDim Preserve Lines(I)
	Lines(I) = SrcFile.ReadLine
	If (I = 0) and (Left(Lines(I), Len(BOM)) = BOM) Then
		HasBOM = 1
		Lines(I) = Right(Lines(I), Len(Lines(I)) - Len(BOM))
	End If
	I = I + 1
Loop
SrcFile.Close
' Calculate ids
Dim Blank, Continued, IDs(), J, PropName, S, SectName, SList
Blank = True
Continued = False
ReDim IDs(UBound(Lines))
PropName = Chr(0)
SectName = Chr(0)
For I = 0 To UBound(Lines)
	S = Trim(Lines(I))
	If S = "" Then ' Blank
		Blank = True
		Continued = False
	ElseIf Continued Then ' Continuation of previous
		If Right(S, 1) <> "\" Then
			Continued = False
		End If
	ElseIf Left(S, 1) = ";" Then ' Comment
	ElseIf Left(S, 1) = "[" Then ' Section
		Blank = False
		PropName = Chr(0)
		SList = Split(S, "]", -1, vbTextCompare)
		If IsArray(SList) Then
			SectName = Mid(SList(0), 2)
		Else
			SectName = Mid(S, 2)
		End If
		If SectName = "" Then
			SectName = Chr(0)
		End If
	Else ' Property
		Blank = False
		If Right(S, 1) = "\" Then
			S = Left(S, Len(S) - 1)
			Continued = True
		End If
		SList = Split(S, "=", -1, vbTextCompare)
		If IsArray(SList) Then
			PropName = SList(0)
		Else
			PropName = S
		End If
		If PropName = "" Then
			PropName = Chr(0)
		End If
	End If
	If Blank Then
		S = ""
	Else
		S = SectName & vbTab & PropName
	End If
	IDs(I) = S
	If (S <> "") And (I > 0) Then
		J = I - 1
		Do While (IDs(J) = "")
			IDs(J) = S
			If J = 0 Then
				Exit Do
			End If
			J = J - 1
		Loop
	End If
Next
For I = 0 To UBound(Lines)
	If IDs(I) = "" Then
		IDs(I) = vbTab
	End If
	IDs(I) = IDs(I) & vbTab & Right("0000000000" & I, 10)
Next
' Sort
QuickSort 0, UBound(Lines)
' Save
Dim TgtFile
Set TgtFile = FileSys.CreateTextFile(WScript.Arguments(1), True, CodePage = TristateTrue)
If HasBOM <> 0 Then
	Lines(0) = BOM & Lines(0)
End If
For I = 0 To UBound(Lines)
	TgtFile.WriteLine Lines(I)
Next
TgtFile.Close

Sub QuickSort(Lo, Hi)
	Dim I, J, P, T
	Do
		I = Lo
		J = Hi
		P = Int((Lo + Hi) / 2)
		Do
			Do While IDs(P) > IDs(I)
				I = I + 1
			Loop
			Do While IDs(J) > IDs(P)
				J = J - 1
			Loop
			If I > J Then
				Exit Do
			End If
			T = IDs(I)
			IDs(I) = IDs(J)
			IDs(J) = T
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