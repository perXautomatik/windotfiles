//Next, I would create a class called Kassa that inherits from UserControl and contains the controls for the Kassa tab. The Kassa class will also have a constructor that initializes and positions the controls on the UserControl. For example:
// This is a code block
using System;
using System.Windows.Forms;

class Kassa : UserControl
{
    // Declare the controls for the Kassa tab as members
    private Label stockLabel;
    private TextBox stockTextBox;
    private Label priceLabel;
    private TextBox priceTextBox;
    private Label nameLabel;
    private TextBox nameTextBox;

    // Constructor for the Kassa class
    public Kassa()
    {
        // Initialize the controls for the Kassa tab
        stockLabel = new Label();
        stockTextBox = new TextBox();
        priceLabel = new Label();
        priceTextBox = new TextBox();
        nameLabel = new Label();
        nameTextBox = new TextBox();

        // Set the properties of the stock label
        stockLabel.Text = "Stock";
        stockLabel.Location = new System.Drawing.Point(150, 50);
        stockLabel.AutoSize = true;

        // Set the properties of the stock text box
        stockTextBox.Location = new System.Drawing.Point(200, 50);
        stockTextBox.Size = new System.Drawing.Size(100, 20);
        
        // Set the properties of the price label
        priceLabel.Text = "Price";
        priceLabel.Location = new System.Drawing.Point(150, 100);
        priceLabel.AutoSize = true;

        // Set the properties of the price text box
        priceTextBox.Location = new System.Drawing.Point(200, 100);
        priceTextBox.Size = new System.Drawing.Size(100, 20);

        // Set the properties of the name label
        nameLabel.Text = "Name";
        nameLabel.Location = new System.Drawing.Point(150, 150);
        nameLabel.AutoSize = true;

        // Set the properties of the name text box
        nameTextBox.Location = new System.Drawing.Point(200, 150);
        nameTextBox.Size = new System.Drawing.Size(100, 20);

        // Add the controls to the UserControl
        this.Controls.Add(stockLabel);
        this.Controls.Add(stockTextBox);
        this.Controls.Add(priceLabel);
        this.Controls.Add(priceTextBox);
        this.Controls.Add(nameLabel);
        this.Controls.Add(nameTextBox);
    }
}
