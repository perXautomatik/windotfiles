# Importera modulen som innehåller funktionen Remove-DuplicateFiles
Import-Module .\DupeOrganizing.ps1

# Definiera några exempeldata för att testa funktionen
$exampleData = @(
    [PSCustomObject]@{
        Name = 'File1.txt'
        Size = 100
        Path = 'C:\Temp\File1.txt'
    }
    [PSCustomObject]@{
        Name = 'File2.txt'
        Size = 200
        Path = 'C:\Temp\File2.txt'
    }
    [PSCustomObject]@{
        Name = 'File3.txt'
        Size = 100
        Path = 'C:\Temp\Subfolder\File3.txt'
    }
    [PSCustomObject]@{
        Name = 'File4.txt'
        Size = 300
        Path = 'C:\Temp\Subfolder\File4.txt'
    }
)

# Definiera en delegerad funktion för att ta bort filer som har samma storlek och namn
$deleteDelegate = {
    param(
        $a, # Den aktuella filen
        $b # De andra filerna som har samma storlek eller namn
    )

    # Ta bort den aktuella filen om den har samma namn som någon av de andra filerna
    if ($a.Name -in $b.Name) {
        Write-Host "Deleting $($a.Path)"
        Remove-Item -Path $a.Path -Force
    }
}

# Skriv ett pester-test för att kontrollera att funktionen Remove-DuplicateFiles fungerar som förväntat
Describe 'Remove-DuplicateFiles' {

    # Testa vad som händer när funktionen anropas med exempeldata och delegerad funktion
    It 'Removes files that have the same size and name' {

        # Anropa funktionen med exempeldata och delegerad funktion
        Remove-DuplicateFiles -Initial $exampleData -DeleteDelegate $deleteDelegate

        # Kontrollera att endast två filer finns kvar i C:\Temp-mappen
        $remainingFiles = Get-ChildItem -Path C:\Temp -Recurse | Where-Object { $_.Name -like 'File*.txt' }
        $remainingFiles.Count | Should -Be 2

        # Kontrollera att de kvarvarande filerna är File2.txt och File4.txt
        $remainingFiles.Name | Should -Contain 'File2.txt'
        $remainingFiles.Name | Should -Contain 'File4.txt'
    }
}
