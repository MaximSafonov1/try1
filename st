import os
import xml.etree.ElementTree as ET
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import re

# Folder containing XML files
FOLDER_PATH = "Canada-Car"

def parse_xml_files(folder_path: str) -> pd.DataFrame:
    """
    Parses all XML files in the given folder and extracts plate region and plate number information.
    
    Args:
        folder_path (str): Path to the folder containing XML files.
    
    Returns:
        pd.DataFrame: DataFrame containing extracted plate regions and plate numbers.
    """
    data = []
    for file in os.listdir(folder_path):
        if file.endswith(".xml"):
            tree = ET.parse(os.path.join(folder_path, file))
            root = tree.getroot()
            
            for plate in root.findall(".//plate"):
                region = plate.find("plate_region").text if plate.find("plate_region") is not None else "Unknown"
                plate_number = plate.find("plate_number").text if plate.find("plate_number") is not None else "Unknown"
                
                data.append({
                    "region": region.strip() if region else "Unknown",
                    "plate_number": plate_number.strip() if plate_number else "Unknown"
                })
    return pd.DataFrame(data)

# Read data
df = parse_xml_files(FOLDER_PATH)

# Count number of annotations per region
region_counts = df["region"].value_counts()
print(region_counts)

# Check for missing regions
missing_regions = (df["region"] == "Unknown").sum()
print(f"Missing regions: {missing_regions}")

# Calculate plate number length
df["plate_length"] = df["plate_number"].apply(len)

# Check for hyphens in plate numbers
df["has_hyphen"] = df["plate_number"].apply(lambda x: 1 if "-" in x else 0)

# Count number of plates with hyphens by region
hyphen_counts_by_region = df.groupby("region")["has_hyphen"].sum()

# Visualization: distribution by regions
plt.figure(figsize=(12, 6))
sns.barplot(x=region_counts.index, y=region_counts.values)
plt.xticks(rotation=45)
plt.title("Number of Annotations by Region")
plt.xlabel("Region")
plt.ylabel("Count")
plt.show()

# Visualization: plate number length by region
plt.figure(figsize=(12, 6))
sns.boxplot(x=df["region"], y=df["plate_length"])
plt.xticks(rotation=45)
plt.title("Plate Number Length Distribution by Region")
plt.xlabel("Region")
plt.ylabel("Plate Number Length")
plt.show()

# Visualization: number of plates with hyphens
plt.figure(figsize=(6, 6))
sns.countplot(x=df["has_hyphen"], palette=["blue", "orange"])
plt.xticks([0, 1], ["Without Hyphen", "With Hyphen"])
plt.title("Plates with Hyphen vs. Without Hyphen")
plt.show()

# Visualization: number of plates with hyphens by region
plt.figure(figsize=(12, 6))
sns.barplot(x=hyphen_counts_by_region.index, y=hyphen_counts_by_region.values)
plt.xticks(rotation=45)
plt.title("Number of Plates with Hyphens by Region")
plt.xlabel("Region")
plt.ylabel("Count")
plt.show()
