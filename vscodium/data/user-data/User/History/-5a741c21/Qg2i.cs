using System;
using System.Collections.Generic;
using System.Linq;

namespace Karlstad4Butik
{
    public struct Metadata
    {
        public String Type;
        public Dictionary<String, String> Feilds;

        /// <summary>
        /// Initializes a new instance of the <see cref="Metadata"/> class.
        /// </summary>
        /// <param name="strings">The strings.</param>
        public Metadata(List<string> strings) : this()
        {
            Feilds = new Dictionary<string, string>();
            Dictionary<string, string> FieldsX = Feilds;

            Type = strings[3];

            strings.Skip(4)
                .ToList()
                .ForEach(q => FieldsX.Add(q.Split('=')[0], q.Split('=')[1]));
        }

        // This is a code block
        public Metadata(string data) : this()
        {
            // Split the string by commas
            string[] values = data.Split(',');

            // Check if the values array has at least two elements
            if (values.Length >= 2)
            {
                // Assign the first value to the Type property
                Type = values[0];

                // Initialize the Feilds dictionary
                Feilds = new Dictionary<string, string>();

                // Loop through the remaining values and add them to the Feilds dictionary
                for (int i = 1; i < values.Length; i++)
                {
                    // Split each value by '='
                    string[] pair = values[i].Split('=');

                    // Check if the pair array has two elements
                    if (pair.Length == 2)
                    {
                        // Add the pair to the Feilds dictionary
                        Feilds.Add(pair[0], pair[1]);
                    }
                    else
                    {
                        // Throw an exception if the data format is invalid
                        throw new ArgumentException("Invalid data format");
                    }
                }
            }
            else
            {
                // Throw an exception if the data format is invalid
                throw new ArgumentException("Invalid data format");
            }
        }

        //For the constructor that accepts a DataTable type, I would use the DataTable.Rows and DataTable.Columns properties to access the data in the table and assign the values to the Type and Feilds properties. For example:
        // This is a code block
        public Metadata(DataTable table) : this()
        {
            // Check if the table has at least one row and one column
            if (table.Rows.Count > 0 && table.Columns.Count > 0)
            {
                // Assign the first cell value to the Type property
                Type = table.Rows[0][0].ToString();

                // Initialize the Feilds dictionary
                Feilds = new Dictionary<string, string>();

                // Loop through the remaining cells in the first row and add them to the Feilds dictionary
                for (int i = 1; i < table.Columns.Count; i++)
                {
                    // Get the cell value as a string
                    string value = table.Rows[0][i].ToString();

                    // Split the value by '='
                    string[] pair = value.Split('=');

                    // Check if the pair array has two elements
                    if (pair.Length == 2)
                    {
                        // Add the pair to the Feilds dictionary
                        Feilds.Add(pair[0], pair[1]);
                    }
                    else
                    {
                        // Throw an exception if the data format is invalid
                        throw new ArgumentException("Invalid data format");
                    }
                }
            }
            else
            {
                // Throw an exception if the table is empty
                throw new ArgumentException("Empty table");
            }
        }

        /// <summary>
        ///             Böcker
        ///            Namn* Pris*Författare Genre Format Språk
        ///                         Dataspel
        ///          Namn* Pris*Plattform
        ///                   Filmer
        ///    Namn* Pris*Format Speltid
        /// </summary>
        /// <returns>A string.</returns>
        public override string ToString()
        {
            string returnString = $"{Type},";

            Feilds.ToList().ForEach(s => returnString += ($"{s.Key}={s.Value}"));
            return returnString;
        }

    }
}