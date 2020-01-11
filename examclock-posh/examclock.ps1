# JCQ Instructions for Conduction Examinations, Section 11
# 11.7 A reliable clock (analogue or digital) must be visible to each candidate in the examination room.
# The clock must be big enough for all candidates to read clearly.
# The clock must show the actual time at which the examination starts.
# Countdown and ‘count up’ clocks are not permissible.

# 11.9 A board/flipchart/whiteboard should be visible to all candidates showing the:
#     a) centre number, subject title and paper number; and
#     b) the actual starting and finishing times, and date, of each examination.


Add-Type -AssemblyName PresentationFramework

$xamlPath = if ($PSScriptRoot) {$PSScriptRoot} else {Get-Location}
$xamlPath = Join-Path $xamlPath 'examclock.xaml'

try {
    [xml]$xaml = Get-Content -Path $xamlPath -ErrorAction Stop
    $window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
} catch {
    Write-Error "Error reading $xamlPath, exiting"
    exit 1
}

$clock = $window.FindName('Clock')
$date = $window.FindName('Date')

function Update-Time {
    $clock.Text = "$(Get-Date -Format T)"
    $date.Text = "$(Get-Date -Format d)"
}

# Add some placeholder text. Sure would be nice if we could use TextBox.PlaceholderText
$centreNumberBox = $window.FindName("CentreNumber")
$centreNumberPlaceholder = '00000'
$centreNumberBox.Add_GotFocus({
    if ($centreNumberBox.Text -eq $centreNumberPlaceholder) {$centreNumberBox.Text = ''}
})
$centreNumberBox.Add_LostFocus({
    if ($centreNumberBox.Text -eq '') {$centreNumberBox.Text = $centreNumberPlaceholder}
})

$examDetailsBox = $window.FindName("ExamDetails")
$examDetailsPlaceholder = 'Exam details here: subject title, paper number, start, and end times'
$examDetailsBox.Add_GotFocus({
    if ($examDetailsBox.Text -eq $examDetailsPlaceholder) {$examDetailsBox.Text = ''}
})
$examDetailsBox.Add_LostFocus({
    if ($examDetailsBox.Text -eq '') {$examDetailsBox.Text = $examDetailsPlaceholder}
})


$window.Add_SourceInitialized({
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = New-TimeSpan -Seconds 1
    $timer.Add_Tick({
        Update-Time
    })
    $timer.Start()
    Update-Time
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

    $window.ShowDialog() | Out-Null
} finally {
    $ste::SetThreadExecutionState($ES_CONTINUOUS)
}
