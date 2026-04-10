using System.Data;
using System.Windows;
using System.Windows.Controls;

namespace GymManagementApp
{
    public partial class ManageMembers : Page
    {
        public ManageMembers()
        {
            InitializeComponent();
            RefreshGrid();
        }

        // ── Grid ─────────────────────────────────────────────────────

        private void RefreshGrid()
        {
            try
            {
                dgManageMembers.ItemsSource = DatabaseHelper.GetAllMembers().DefaultView;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Could not load members:\n{ex.Message}",
                                "Database Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void DgManageMembers_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgManageMembers.SelectedItem is not DataRowView row)
                return;

            txtMemberID.Text   = row["MemberID"].ToString();
            txtMemberName.Text = $"{row["FirstName"]} {row["LastName"]}".Trim();
            txtPhone.Text      = row["Phone"].ToString();

            string memberType = row["MemberType"].ToString()!;
            foreach (ComboBoxItem item in cbMemberType.Items)
            {
                if (item.Content.ToString() == memberType)
                {
                    cbMemberType.SelectedItem = item;
                    break;
                }
            }
        }

        // ── Helpers ───────────────────────────────────────────────────

        private (string First, string Last) SplitName(string fullName)
        {
            fullName = fullName.Trim();
            int space = fullName.IndexOf(' ');
            if (space < 0)
                return (fullName, string.Empty);
            return (fullName[..space], fullName[(space + 1)..]);
        }

        private string SelectedMemberType =>
            cbMemberType.SelectedItem is ComboBoxItem item ? item.Content.ToString()! : string.Empty;

        // ── Button handlers ───────────────────────────────────────────

        private void BtnAdd_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtMemberName.Text) ||
                string.IsNullOrWhiteSpace(SelectedMemberType))
            {
                MessageBox.Show("Please enter a Member Name and select a Membership Type.",
                                "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var (first, last) = SplitName(txtMemberName.Text);

            bool success = DatabaseHelper.AddMember(first, last, txtPhone.Text, SelectedMemberType);

            if (success)
            {
                MessageBox.Show($"{first} {last} has been added successfully.",
                                "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                BtnReset_Click(sender, e);
                RefreshGrid();
            }
            else
            {
                MessageBox.Show("Failed to add member. Please check your database connection.",
                                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void BtnUpdate_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtMemberID.Text, out int id))
            {
                MessageBox.Show("Please enter a valid numeric Member ID to update.",
                                "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtMemberName.Text) ||
                string.IsNullOrWhiteSpace(SelectedMemberType))
            {
                MessageBox.Show("Please enter a Member Name and select a Membership Type.",
                                "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var (first, last) = SplitName(txtMemberName.Text);

            bool success = DatabaseHelper.UpdateMember(id, first, last, txtPhone.Text, SelectedMemberType);

            if (success)
            {
                MessageBox.Show($"Member ID {id} updated successfully.",
                                "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                BtnReset_Click(sender, e);
                RefreshGrid();
            }
            else
            {
                MessageBox.Show($"No member found with ID {id}, or update failed.",
                                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void BtnDelete_Click(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(txtMemberID.Text, out int id))
            {
                MessageBox.Show("Please enter a valid numeric Member ID to delete.",
                                "Validation Error", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            var result = MessageBox.Show(
                $"Are you sure you want to permanently delete Member ID {id}?",
                "Confirm Deletion", MessageBoxButton.YesNo, MessageBoxImage.Warning);

            if (result == MessageBoxResult.Yes)
            {
                bool success = DatabaseHelper.DeleteMember(id);

                if (success)
                {
                    MessageBox.Show($"Member ID {id} has been deleted.",
                                   "Deleted", MessageBoxButton.OK, MessageBoxImage.Information);
                    BtnReset_Click(sender, e);
                    RefreshGrid();
                }
                else
                {
                    MessageBox.Show($"No member found with ID {id}.",
                                   "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private void BtnReset_Click(object sender, RoutedEventArgs e)
        {
            txtMemberID.Clear();
            txtMemberName.Clear();
            txtPhone.Clear();
            cbMemberType.SelectedIndex = -1;
            dgManageMembers.SelectedItem = null;
        }
    }
}
