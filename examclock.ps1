[xml]$xaml = Get-Content -Path $PSScriptRoot\examclock.xaml
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

$clock = $window.FindName('Clock')

$updateTime = {
    $clock.Text = "$(Get-Date -format 'h:mm')" # 12-hour clock without seconds probably preferable
}

$window.Add_SourceInitialized({
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = New-TimeSpan -Seconds 1
    $timer.Add_Tick({
        $updateTime.Invoke()
    })
    $timer.Start()
})

$updateTime.Invoke()

$window.ShowDialog()