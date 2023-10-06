
//First, I would create a class called Butik that inherits from Form and contains a TabControl as a member. The TabControl will have two TabPages, one for Kassa and one for Lagerarbete. The Butik class will also have a constructor that initializes the TabControl and adds the TabPages to it. For example:

// This is a code block
using System;
using System.Windows.Forms;

class Butik : Form
{
    // Declare a TabControl as a member
    private TabControl tabControl;

    // Constructor for the Butik class
    public Butik()
    {
        // Initialize the TabControl
        tabControl = new TabControl();

        // Set the properties of the TabControl
        tabControl.Dock = DockStyle.Fill; // Fill the entire form
        tabControl.Alignment = TabAlignment.Left; // Align the tabs to the left
        tabControl.SizeMode = TabSizeMode.Fixed; // Fix the size of the tabs
        tabControl.ItemSize = new System.Drawing.Size(30, 120); // Set the size of the tabs

        // Create two TabPages, one for Kassa and one for Lagerarbete
        TabPage kassaPage = new TabPage("Kassa");
        TabPage lagerarbetePage = new TabPage("Lagerarbete");

        // Add the TabPages to the TabControl
        tabControl.TabPages.Add(kassaPage);
        tabControl.TabPages.Add(lagerarbetePage);

        // Add the TabControl to the Form
        this.Controls.Add(tabControl);
    }
}
