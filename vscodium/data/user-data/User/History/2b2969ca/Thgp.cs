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
