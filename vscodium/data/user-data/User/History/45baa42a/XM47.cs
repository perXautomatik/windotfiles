//Finally, I would create a class called Lagerarbete that inherits from UserControl and contains the controls for the Lagerarbete tab. The Lagerarbete class will also have a constructor that initializes and positions the controls on the UserControl. For example:
// This is a code block
using System;
using System.Windows.Forms;

class Lagerarbete : UserControl
{
    // Declare the controls for the Lagerarbete tab as members
    private Label formatLabel;
    private TextBox formatTextBox;
    private Label idLabel;
    private TextBox idTextBox;
    private Label nameLabel;
    private TextBox nameTextBox;
    private Label priceLabel;
    private TextBox priceTextBox;
    private Label stockLabel;
    private TextBox stockTextBox;
    private Label lagerTillLabel;
    private TextBox lagerTillTextBox;

    // Constructor for the Lagerarbete class
    public Lagerarbete()
    {
        // Initialize the controls for the Lagerarbete tab
        formatLabel = new Label();
        formatTextBox = new TextBox();
        idLabel = new Label();
        idTextBox = new TextBox();
        nameLabel = new Label();
        nameTextBox = new TextBox();
        priceLabel = new Label();
        priceTextBox = new TextBox();
        stockLabel = new Label();
        stockTextBox = new TextBox();
        lagerTillLabel = new Label();
        lagerTillTextBox = new TextBox();

        // Set the properties of the format label
        formatLabel.Text = "Format";
        formatLabel.Location = new System.Drawing.Point(150, 50);
        formatLabel.AutoSize = true;

        // Set the properties of the format text box
        formatTextBox.Location = new System.Drawing.Point(200, 50);
        formatTextBox.Size = new System.Drawing.Size(100, 20);

        // Set the properties of the id label
        idLabel.Text = "Id";
        idLabel.Location = new System.Drawing.Point(150, 100);
        idLabel.AutoSize = true;

        // Set the properties of the id text box
        idTextBox.Location = new System.Drawing.Point(200, 100);
        idTextBox.Size = new System.Drawing.Size(100, 20);

        // Set the properties of the name label
        nameLabel.Text = "Name";
        nameLabel.Location = new System.Drawing.Point(150, 150);
        nameLabel.AutoSize = true;

        // Set the properties of the name text box
        nameTextBox.Location = new System.Drawing.Point(200, 150);
        nameTextBox.Size = new System.Drawing.Size(100, 20);

        // Set the properties of the price label
        priceLabel.Text = "Price";
        priceLabel.Location = new System.Drawing.Point(150, 200);
        priceLabel.AutoSize = true;

        // Set the properties of the price text box
        priceTextBox.Location = new System.Drawing.Point(200, 200);
        priceTextBox.Size = new System.Drawing.Size(100, 20);

        // Set the properties of the stock label
        stockLabel.Text = "Stock";
        stockLabel.Location = new System.Drawing.Point(150, 250);
        stockLabel.AutoSize = true;

        // Set the properties of the stock text box
        stockTextBox.Location = new System.Drawing.Point(200, 250);
        stockTextBox.Size = new System.Drawing.Size(100, 20);

        // Set the properties of the lager till label
        lagerTillLabel.Text = "Lager Till";
        lagerTillLabel.Location = new System.Drawing.Point(150, 300);
        lagerTillLabel.AutoSize = true;

        // Set the properties of the lager till text box
        lagerTillTextBox.Location = new System.Drawing.Point(200, 300);
        lagerTillTextBox.Size = new System.Drawing.Size(100, 20);

         // Add the controls to the UserControl
         this.Controls.Add(formatLabel);
         this.Controls.Add(formatTextBox);
         this.Controls.Add(idLabel);
         this.Controls.Add(idTextBox);
         this.Controls.Add(nameLabel);
         this.Controls.Add(nameTextBox);
         this.Controls.Add(priceLabel);
         this.Controls.Add(priceTextBox);
         this.Controls.Add(stockLabel);
         this.Controls.Add(stockTextBox);
         this.Controls.Add(lagerTillLabel);
         this.Controls.Add(lagerTillTextBox);       
    }
}
