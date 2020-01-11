using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;

namespace examclock
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

            Clock.Text = DateTime.Now.ToLongTimeString();
            Date.Text = DateTime.Now.ToShortDateString();

            DispatcherTimer Timer = new DispatcherTimer();

            Timer.Interval = new TimeSpan(0, 0, 1);
            Timer.Tick += new EventHandler(UpdateTime);
            Timer.Start();
        }

        private void UpdateTime(object sender, EventArgs e)
        {
            Clock.Text = DateTime.Now.ToLongTimeString();
            Date.Text = DateTime.Now.ToShortDateString();
        }


    }
}
