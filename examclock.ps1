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
    $updateTime.Invoke()
})

# Attempt to prevent the computer sleeping/turning off the display.
# Requires this to be allowed in power plan options, it is by default.
# An alternative would be using Presentation Mode via presentationsettings.exe /start
# https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-setthreadexecutionstate
# https://gist.github.com/CMCDragonkai/bf8e8b7553c48e4f65124bc6f41769eb
# https://github.com/stefanstranger/PowerShell/blob/master/Examples/SuspendPowerPlan.ps1

$Code=@'
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
public static extern void SetThreadExecutionState(uint esFlags);
'@

$ste = Add-Type -memberDefinition $Code -name System -namespace Win32 -passThru

# Requests that the other EXECUTION_STATE flags set remain in effect until
# SetThreadExecutionState is called again with the ES_CONTINUOUS flag set and
# one of the other EXECUTION_STATE flags cleared.
$ES_CONTINUOUS = [uint32]"0x80000000"
$ES_DISPLAY_REQUIRED = [uint32]"0x00000002"

try {
    $ste::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_DISPLAY_REQUIRED)

    $window.ShowDialog()
} finally {
    $ste::SetThreadExecutionState($ES_CONTINUOUS)
}
