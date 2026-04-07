using System.Windows;
using System.Windows.Controls;

namespace GymManagementApp
{
    public partial class ViewMembers : Page
    {
        public ViewMembers()
        {
            InitializeComponent();
            LoadAllMembers();
        }

        // Populate the grid on page load
        private void LoadAllMembers()
        {
            try
            {
                dgMembers.ItemsSource = DatabaseHelper.GetAllMembers().DefaultView;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Could not load members:\n{ex.Message}",
                                "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void BtnSearch_Click(object sender, RoutedEventArgs e)
        {
            string id        = txtSearchID.Text.Trim();
            string firstName = txtSearchFirstName.Text.Trim();
            string lastName  = txtSearchLastName.Text.Trim();

            try
            {
                var results = DatabaseHelper.SearchMembers(id, firstName, lastName);
                dgMembers.ItemsSource = results.DefaultView;

                if (results.Rows.Count == 0)
                    MessageBox.Show("No members found matching the search criteria.",
                                    "No Results", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Search failed:\n{ex.Message}",
                                "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
