using System;
using System.Windows;

namespace WIthoutStudio
{
    public class EntryPoint
    {
        // All WPF applications should execute on a single-threaded apartment (STA) thread
        [STAThread]
        public static void Main()
        {
            Application app = new Application();
            app.Run(new Window());
        
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