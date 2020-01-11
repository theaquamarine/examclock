using Microsoft.Win32;
using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Threading;

namespace examclock
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern void SetThreadExecutionState(uint esFlags);

        uint ES_CONTINUOUS = 0x80000000;
        uint ES_DISPLAY_REQUIRED = 0x00000002;

        string ExamDetailsPlaceholder;

        public MainWindow()
        {
            InitializeComponent();

            Clock.Text = DateTime.Now.ToLongTimeString();
            Date.Text = DateTime.Now.ToShortDateString();

            DispatcherTimer Timer = new DispatcherTimer();

            Timer.Interval = new TimeSpan(0, 0, 1);
            Timer.Tick += new EventHandler(UpdateTime);
            Timer.Start();

            RegistryKey UserKey = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\examclock");
            RegistryKey MachineKey = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\examclock");

            // Set CentreNumber from, in order of precedence, HKCU, HKLM, "00000"
            string UserCentreNumber = UserKey?.GetValue("CentreNumber")?.ToString();
            string MachineCentreNumber = MachineKey?.GetValue("CentreNumber")?.ToString();
            CentreNumber.Text = UserCentreNumber ?? MachineCentreNumber ?? CentreNumber.Text;

            CentreNumber.TextChanged += CentreNumber_TextChanged;

            ExamDetailsPlaceholder = ExamDetails.Text;
            ExamDetails.GotFocus += ExamDetails_GotFocus;
            ExamDetails.LostFocus += ExamDetails_LostFocus;
        }

        protected override void OnInitialized(EventArgs e)
        {
            // Attempt to prevent the computer sleeping/turning off the display.
            // Requires this to be allowed in power plan options, it is by default.
            // An alternative would be using Presentation Mode via presentationsettings.exe /start
            // https://docs.microsoft.com/en-us/windows/desktop/api/winbase/nf-winbase-setthreadexecutionstate
            // https://gist.github.com/CMCDragonkai/bf8e8b7553c48e4f65124bc6f41769eb
            // https://github.com/stefanstranger/PowerShell/blob/master/Examples/SuspendPowerPlan.ps1
            // Can be confirmed with powercfg -requests

            // Requests that the other EXECUTION_STATE flags set remain in effect until
            // SetThreadExecutionState is called again with the ES_CONTINUOUS flag set and
            // one of the other EXECUTION_STATE flags cleared.
            SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED);

            base.OnInitialized(e);
        }

        protected override void OnClosed(EventArgs e)
        {
            SetThreadExecutionState(ES_CONTINUOUS);

            base.OnClosed(e);
        }

        private void UpdateTime(object sender, EventArgs e)
        {
            Clock.Text = DateTime.Now.ToLongTimeString();
            Date.Text = DateTime.Now.ToShortDateString();
        }

        private void CentreNumber_TextChanged(object sender, EventArgs e)
        {
            RegistryKey UserKey = Registry.CurrentUser.CreateSubKey(@"SOFTWARE\examclock");
            UserKey.SetValue("CentreNumber", CentreNumber.Text);
        }

        private void ExamDetails_GotFocus(object sender, EventArgs e)
        {
            if (ExamDetails.Text.Equals(ExamDetailsPlaceholder)) { ExamDetails.Text = ""; }
        }

        private void ExamDetails_LostFocus(object sender, EventArgs e)
        {
            if (ExamDetails.Text.Equals("")) { ExamDetails.Text = ExamDetailsPlaceholder; }
        }

    }
}
