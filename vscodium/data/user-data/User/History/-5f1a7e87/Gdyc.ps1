# Define a function to convert a Beyond Compare setting file to an XML object
function ConvertTo-XmlObject {
    param (
        [string]$FilePath # The path of the Beyond Compare setting file
    )
    # Get the content of the file as a string
    $content = Get-Content -Path $FilePath -Raw
    # Replace the curly braces with angle brackets
    $content = $content -replace '{', '<' -replace '}', '>'
    # Quote the attribute values
    $content = $content -replace '(?<=\s)(\w+)=(\w+)', '$1="$2"'
    # Escape the special characters
    $content = [System.Security.SecurityElement]::Escape($content)
    # Convert the string to an XML object
    $xml = ConvertTo-Xml -InputObject $content -As String -NoTypeInformation
    # Return the XML object
    return $xml
}

# Define a function to convert an XML object to a Beyond Compare setting file
function ConvertTo-BcSettingFile {
    param (
        [xml]$XmlObject, # The XML object to convert
        [string]$FilePath # The path of the Beyond Compare setting file to create or overwrite
    )
    # Convert the XML object to a string
    $content = $XmlObject.OuterXml
    # Unescape the special characters
    $content = [System.Web.HttpUtility]::HtmlDecode($content)
    # Unquote the attribute values
    $content = $content -replace '(?<=\s)(\w+)="(\w+)"', '$1=$2'
    # Replace the angle brackets with curly braces
    $content = $content -replace '<', '{' -replace '>', '}'
    # Set the content of the file with the modified string
    Set-Content -Path $FilePath -Value $content
}

# Example usage: convert a Beyond Compare setting file to an XML object and display it
$xml = ConvertTo-XmlObject -FilePath "C:\Users\user\Documents\BCSessions.bcpkg"
$xml

# Example usage: convert an XML object to a Beyond Compare setting file and save it
ConvertTo-BcSettingFile -XmlObject $xml -FilePath "C:\Users\user\Documents\BCSessions2.bcpkg"
