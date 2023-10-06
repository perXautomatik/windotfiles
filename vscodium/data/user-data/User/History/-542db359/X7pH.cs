using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;

namespace Karlstad4Butik
{
    public partial class Butik
    {
        [Serializable]
        internal partial class InventarieException : Exception
        {
            public InventarieException(string message) : base(message)
            {
            }
        }
    }

    public class Inventarie : Product
    {
        public Metadata metadata;                

        // Constructor that takes a single string as parameter
        public Inventarie(string data) : base(data.Substring(0, data.LastIndexOf(',')))
        {
            // Split the string by commas
            string[] values = data.Split(',');

            // Check if the values array has six elements
            if (values.Length >= 5)
            {                 
                this.metadata = new Metadata(values[5..]);   
            }
            else
            {
                // Throw an exception if the data is invalid
                throw new ArgumentException("Invalid data format");
            }
        }

        public Inventarie(string id1, string name1, string price1, string stock1, Metadata metadata1) : base(id1, name1,
            price1, stock1)
        {
            this.Metadata1 = metadata1;
        }
        
        public Metadata Metadata1
        {
            get => GetMetadata();
            set => throw new NotImplementedException();
        }

        public static Book ToBook(Inventarie a)
        {
            Book q;
            q = new Book(a.Id, a.Name, a.Price, a.Stock, a.metadata.Feilds["genre"],
                a.metadata.Feilds["format"], a.metadata.Feilds["language"]);
            return q;
        }


        public static Game ToGame(Inventarie a)
        {
            Game q;
            q = new Game(a.Id, a.Name, a.Price, a.Stock, a.metadata.Feilds["platform"]);
            return q;
        }

        public static Movie ToMovie(Inventarie a)
        {
            Movie q;
            q = new Movie(a.Id, a.Name, a.Price, a.Stock, a.metadata.Feilds["playtime"],
                a.metadata.Feilds["format"]);
            return q;
        }

        private Metadata GetMetadata()
        {
            // Create a list of strings to store the data
            List<string> data = new List<string>();

            // Add an empty string as the first element
            data.Add("");

            // Add the name, id, and price of the book as the second, third, and fourth elements
            data.Add(this.Name);
            data.Add(this.Id.ToString());
            data.Add(this.Price.ToString());

            // Add the type of the product as the fifth element
            data.Add(GetType().Name);

            foreach (var propertyInfo in this.GetType().GetProperties())
            {
                // Get the name and value of the property
                string name = propertyInfo.Name;
                object value = propertyInfo.GetValue(name);

                // Add the name and value to the data list
                data.Add($"{name}={value}");
            }

            // Convert the list to an array and return it
            data.ToArray();
            return new Metadata(data);
        }

        internal static Product InventarieToProduct(Inventarie a)
        {
            Product q = null;
            switch (a.metadata.Type)
            {
                case "book":
                    q = new Book(a.Id, a.Name, a.Price, a.Stock, a.metadata);
                    break;

                case "game":

                    q = new Game(a.Id, a.Name, a.Price, a.Stock, a.metadata);
                    break;
                case "movie":

                    q = new Movie(a.Id, a.Name, a.Price, a.Stock, a.metadata);
                    break;
                default:
                    break;
            }

            return q;
        }

        internal bool MatchNamePredicate(string productNamn) => this.Name.ToString() == productNamn;

        // Override the ToString method to include the Grade property
        public override string ToString()
        {
            // Call the ToString method of the Person class and append the Grade property
            return base.ToString() + $",{Grade}";
        }

        /// <summary>
        /// Bakes the output with int.
        /// </summary>
        /// <param name="v">The v.</param>
        /// <returns>A string.</returns>
        internal string BakeOutputWithInt(int v)
        {
            return $"{v + ','}{this.ToString()}";
        }
    }
}