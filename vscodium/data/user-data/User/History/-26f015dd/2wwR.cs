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

    }
}