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
        }
    }
}