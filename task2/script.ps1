$source = 'Z:\Documents\'
$destination = 'C:\Destination'

Get-ChildItem $source -filter *.txt -recurse | 
  Select-String -List -Pattern "TEXT" |
  Move-Item -Destination $destination