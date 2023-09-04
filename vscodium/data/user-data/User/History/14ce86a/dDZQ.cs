
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity;
using System.Data.SQLite;

// Gist entity class
public class Gist
{
    [Key] // Specify primary key
    [Column("id", TypeName = "TEXT")] // Configure id column
    [Required] // Make it required
    public string Id { get; set; } // Id property

    [Column("visibility", TypeName = "TEXT")] // Configure visibility column
    [Required] // Make it required
    public string Visibility { get; set; } // Visibility property

    [Column("description", TypeName = "TEXT")] // Configure description column
    [Required] // Make it required
    public string Description { get; set; } // Description property

    [Column("updated_at", TypeName = "DATETIME")] // Configure updated_at column
    [Required] // Make it required
    public DateTime UpdatedAt { get; set; } // UpdatedAt property

    public virtual ICollection<File> Files { get; set; } // Navigation property for files
}

// File entity class
public class File
{
    [Key] // Specify primary key
    [Column("id", TypeName = "TEXT")] // Configure id column
    [Required] // Make it required
    public string Id { get; set; } // Id property

    [Key] // Specify primary key
    [Column("filename", TypeName = "TEXT")] // Configure filename column
    [Required] // Make it required
    public string Filename { get; set; } // Filename property

    [Column("filecontent", TypeName = "BLOB")] // Configure filecontent column
    [Required] // Make it required
    public byte[] FileContent { get; set; } // FileContent property

    public virtual Gist Gist { get; set; } // Navigation property for gist
}

// GistDbContext class
public class GistDbContext : DbContext
{
    public DbSet<Gist> Gists { get; set; } // DbSet property for gists
    public DbSet<File> Files { get; set; } // DbSet property for files

    // Specify the connection string and the SQLite provider
    public GistDbContext() : base(new SQLiteConnection()
    {
        ConnectionString = new SQLiteConnectionStringBuilder()
        { DataSource = "Gist.db", ForeignKeys = true }.ConnectionString
    }, true)
    { }

    protected override void OnModelCreating(DbModelBuilder modelBuilder)
    {
        // Configure Gist entity
        modelBuilder.Entity<Gist>()
            .ToTable("Gists") // Map to Gists table
            .HasMany(g => g.Files) // Configure one-to-many relationship with Files
            .WithRequired(f => f.Gist) // Make it required
            .HasForeignKey(f => f.Id); // Specify foreign key

        // Configure File entity
        modelBuilder.Entity<File>()
            .ToTable("Files") // Map to Files table
            .HasKey(f => new { f.Id, f.Filename }) // Specify composite primary key
            .Property(f => f.Id) // Configure Id column
            .HasColumnOrder(0); // Specify column order

        modelBuilder.Entity<File>()
            .Property(f => f.Filename) // Configure Filename column
            .HasColumnOrder(1); // Specify column order

        modelBuilder.Entity<File>()
            .Property(f => f.FileContent) // Configure FileContent column
            .HasColumnType("BLOB"); // Specify column type
    }
}
