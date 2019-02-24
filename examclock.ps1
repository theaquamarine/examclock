[xml]$xaml = Get-Content -Path $PSScriptRoot\examclock.xaml
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

$clock = $window.FindName('Clock')
$clock.Text = "$(Get-Date -format 'h:mm')" # 12-hour clock without seconds probably preferable

$window.ShowDialog()