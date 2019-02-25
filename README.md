A clock/display for UK examinations, aimed to meet JCQ rules.

_[JCQ Instructions for Conduction Examinations, Section 11](https://www.jcq.org.uk/exams-office/ice---instructions-for-conducting-examinations/instructions-for-conducting-examinations-2018-2019)_

11.7 A reliable clock (analogue or digital) must be visible to each candidate in the examination room.
- The clock must be big enough for all candidates to read clearly.
- The clock must show the actual time at which the examination starts.
- Countdown and ‘count up’ clocks are not permissible.

11.9 A board/flipchart/whiteboard should be visible to all candidates showing the:
- a) centre number, subject title and paper number; and
- b) the actual starting and finishing times, and date, of each examination.

## Running

`powershell examclock.ps1`

Alternatively, packages with [PS2EXE-GUI](https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5): `ps2exe.ps1 .\examclock.ps1 .\examclock.exe -verbose -noConsole` and distribute examclock.xaml with the .exe

- The packaged version works as a Custom User Interface via [Group Policy](https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.WindowsLogon2::CustomShell)
- It probably works using [Shell Launcher](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/shell-launcher), though I've not tried.

#### Requirements

The GUI is built using WPF, so this only runs on Windows. For the same reason, this cannot run in PowerShell's constrained language mode.
