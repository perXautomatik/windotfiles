using System;
using System.Collections.Generic;
using System.Linq;

namespace Karlstad4Butik
{
    public class Product
    {
        protected string id1;
        protected string name1;
        protected string price1;
        protected string stock1;

        public Product(string id1, string name1, string price1, string stock1)
        {
            this.id1 = id1;
            this.name1 = name1;
            this.price1 = price1;
            this.stock1 = stock1;
        }

// initierar inventarien med hjälp av initeringsträng
        public Product()
        {
        }
// This is a code block


        public Product(string q) : this()
        {
            List<string> stringx = new List<string>(q.Split(','));
            _ = stringx[0];
            this.name = stringx[1];
            float.TryParse(stringx[2], out this.Pris);
        }
        
        // Constructor that takes a single string as parameter
        public Product(string data)
        {
            // Split the string by commas
            string[] values = data.Split(',');

            // Check if the values array has five elements
            if (values.Length == 5)
            {
                // Call the other constructor with the values as arguments
                this(values[0], int.Parse(values[1]), values[2], values[3], values[4]);
            }
            else
            {
                // Throw an exception if the data is invalid
                throw new ArgumentException("Invalid data format");
            }
        }

        // Constructor that takes five parameters
        public Product(string name, int age, string gender, string occupation, string hobby)
        {
            // Assign the parameters to the properties
            Name = name;
            Age = age;
            Gender = gender;
            Occupation = occupation;
            Hobby = hobby;
        }



        protected Product(Item registerCurrentItem)
        {
            throw new NotImplementedException();
        }

        protected Product(string id1)
        {
            throw new NotImplementedException();
        }

        internal static Product fromHash(string q)
        {
            throw new NotImplementedException();
        }
    }
}