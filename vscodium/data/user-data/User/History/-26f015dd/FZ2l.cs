using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
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
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore.Sqlite;
using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Data.Sqlite;

namespace WIthoutStudio
{
    public partial class MainWindow : Window
    {
        // Create a connection to the SQLite database
        private SqliteConnection connection = new SqliteConnection("Data Source=files.db");

        public MainWindow()
        {
            InitializeComponent();

            // Open the connection and create the table if it does not exist
            connection.Open();
            var command = connection.CreateCommand();
            command.CommandText = "CREATE TABLE IF NOT EXISTS files (path TEXT, content TEXT)";
            command.ExecuteNonQuery();

            // Load the history of opened files from the database
            LoadHistory();
        }

        // Load the history of opened files from the database and display them in a list box
        private void LoadHistory()
        {
            // Clear the list box
            listBox.Items.Clear();

            // Query the database for all the records in the files table
            var command = connection.CreateCommand();
            command.CommandText = "SELECT path, content FROM files";
            var reader = command.ExecuteReader();

            // Loop through the records and add them to the list box
            while (reader.Read())
            {
                // Create a list box item with the file path as the content and the file content as the tag
                var item = new ListBoxItem();
                item.Content = reader.GetString(0);
                item.Tag = reader.GetString(1);

                // Add the item to the list box
              //  listBox.Items.Add(item);
            }
        }

    }
}