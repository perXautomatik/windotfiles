# Load the Accord.NET Framework
Add-Type -Path "C:\path\to\Accord.Math.dll"
Add-Type -Path "C:\path\to\Accord.MachineLearning.dll"

# Create a matrix of vectors
$matrix = [double[,]]::new(4, 2)
$matrix[0, 0] = 1.0
$matrix[0, 1] = 2.0
$matrix[1, 0] = 3.0
$matrix[1, 1] = 4.0
$matrix[2, 0] = 5.0
$matrix[2, 1] = 6.0
$matrix[3, 0] = 7.0
$matrix[3, 1] = 8.0

# Create a KMeans object with the number of clusters
$kmeans = [Accord.MachineLearning.KMeans]::new(2)

# Compute the clusters and centroids
$labels = $kmeans.Learn($matrix)
$centroids = $kmeans.Centroids

# Print the results
Write-Output "The cluster labels are: $labels"
Write-Output "The cluster centroids are: $centroids"
