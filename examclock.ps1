[xml]$xaml = Get-Content -Path $PSScriptRoot\examclock.xaml
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$window.ShowDialog()