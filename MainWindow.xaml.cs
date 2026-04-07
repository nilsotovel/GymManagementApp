using System.Windows;

namespace GymManagementApp
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            // Automatically open the View page on start
            MainFrame.Navigate(new ViewMembers());
        }

        // Navigation logic for Extra Credit
        private void NavView_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Navigate(new ViewMembers());
        }

        private void NavManage_Click(object sender, RoutedEventArgs e)
        {
            MainFrame.Navigate(new ManageMembers());
        }

        private void BtnExit_Click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }
    }
}