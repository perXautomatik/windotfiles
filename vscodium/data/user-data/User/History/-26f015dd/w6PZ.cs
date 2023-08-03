using System;
using System.Collections.Generic;
using System.IO;
//using System.Data.Entity;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
//using Microsoft.Data.Sqlite;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using Microsoft.EntityFrameworkCore;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
//using System.Windows.Shapes;

namespace WpfApp
{
    // Define a model class for the files table
    public class File
    {
        public int Id { get; set; }
        public string Path { get; set; }
        public string Content { get; set; }
    }

    // Define a DbContext class for the files database
    public class FilesContext : DbContext
    {
        public DbSet<File> Files { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            // Use SQLite as the database provider
            optionsBuilder.UseSqlite("Data Source=files.db");
        }
    }

    public partial class MainWindow : Window
    {
        // Create an instance of the DbContext class
        private FilesContext context = new FilesContext();

        public MainWindow()
        {
            InitializeComponent();

            // Ensure the database and the table are created
            context.Database.EnsureCreated();

            // Load the history of opened files from the database
            LoadHistory();
        }

        // Load the history of opened files from the database and display them in a list box
        private void LoadHistory()
        {
            // Clear the list box
            listBox.Items.Clear();

            // Query the database for all the records in the files table
            var files = context.Files.ToList();

            // Loop through the records and add them to the list box
            foreach (var file in files)
            {
                // Create a list box item with the file path as the content and the file content as the tag
                var item = new ListBoxItem();
                item.Content = file.Path;
                item.Tag = file.Content;

                // Add the item to the list box
                listBox.Items.Add(item);
            }
        }

        // Handle the click event of the select file button
        private void SelectFileButton_Click(object sender, RoutedEventArgs e)
        {
            // Create a file dialog to select a text file
            var dialog = new Microsoft.Win32.OpenFileDialog();
            dialog.Filter = "Text files (*.txt)|*.txt";

            // Show the dialog and get the result
            var result = dialog.ShowDialog();

            // If the result is true, meaning a file was selected
            if (result == true)
            {
                // Get the file path and name from the dialog
                var filePath = dialog.FileName;
                var fileName = Path.GetFileName(filePath);

                // Read the file content as a string
                var fileContent = File.ReadAllText(filePath);

                // Display the file name and content in text boxes
                fileNameTextBox.Text = fileName;
                fileContentTextBox.Text = fileContent;

                // Save the file path and content to the database
                SaveFile(filePath, fileContent);
            }
        }

        // Save the file path and content to the database
        private void SaveFile(string filePath, string fileContent)
        {
            // Create a new File object with the file path and content
            var file = new File { Path = filePath, Content = fileContent };

            // Add the File object to the Files DbSet
            context.Files.Add(file);

            // Save the changes to the database
            context.SaveChanges();

            // Reload the history of opened files from the database
            LoadHistory();
        }

        // Handle the selection changed event of the list box
        private void ListBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            // Get the selected item from the list box
            var item = listBox.SelectedItem as ListBoxItem;

            // If there is an item selected
            if (item != null)
            {
                // Get the file path and content from the item's content and tag
                var filePath = item.Content as string;
                var fileContent = item.Tag as string;

                // Display the file name and content in text boxes
                fileNameTextBox.Text = Path.GetFileName(filePath);
                fileContentTextBox.Text = fileContent;
            }
        }

        // Handle the closing event of the window
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            // Dispose the DbContext object
            context.Dispose();
        }
    }
}
