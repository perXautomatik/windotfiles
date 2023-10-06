//To use these classes in your application, you will need to create an instance of the Butik class and set it as your main form. You will also need to create instances of the Kassa and Lagerarbete classes and add them to the TabPages of the TabControl. For example:
// This is a code block
using System;
using System.Windows.Forms;

class Program
{
    [STAThread]
    static void Main()
    {
       // Create an instance of the Butik class
       Butik butikForm = new Butik();

       // Create an instance of the Kassa class
       Kassa kassaControl = new Kassa();

       // Create an instance of the Lagerarbete class
       Lagerarbete lagerarbeteControl = new Lagerarbete();

       // Add the Kassa and Lagerarbete controls to their respective TabPages
       butikForm.tabControl.TabPages[0].Controls.Add(kassaControl);
       butikForm.tabControl.TabPages[1].Controls.Add(lagerarbeteControl);

       // Run the application with the Butik form as the main form
       Application.Run(butikForm); 
    }
}
