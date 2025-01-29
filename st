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
            try:
                tree = ET.parse(os.path.join(folder_path, file))
                root = tree.getroot()
                
                for plate in root.findall(".//plate"):
                    region = plate.find("plate_region").text if plate.find("plate_region") is not None else "Unknown"
                    plate_number = plate.find("plate_number").text if plate.find("plate_number") is not None else "Unknown"
                    
                    data.append({
                        "region": region.strip() if region else "Unknown",
                        "plate_number": plate_number.strip() if plate_number else "Unknown"
                    })
            except ET.ParseError as e:
                print(f"Error parsing {file}: {e}")
    return pd.DataFrame(data)

# Read data
df = parse_xml_files(FOLDER_PATH)

# Count number of annotations per region
region_counts = df["region"].value_counts()
total_plates = len(df)
region_percent = (region_counts / total_plates * 100).round(2)
region_stats = pd.DataFrame({"Count": region_counts, "Percentage": region_percent})
print(region_stats)

# Check for missing regions
missing_regions = (df["region"] == "Unknown").sum()
print(f"Missing regions: {missing_regions}")

# Calculate plate number length
df["plate_length"] = df["plate_number"].apply(len)

# Check for hyphens in plate numbers
df["has_hyphen"] = df["plate_number"].apply(lambda x: 1 if "-" in x else 0)

# Count number of plates with hyphens by region
hyphen_counts_by_region = df.groupby("region")["has_hyphen"].sum()
hyphen_percent_by_region = (hyphen_counts_by_region / region_counts * 100).round(2)
hyphen_stats = pd.DataFrame({"Count": hyphen_counts_by_region, "Percentage": hyphen_percent_by_region})

# Visualization: distribution by regions
plt.figure(figsize=(12, 6))
sns.barplot(x=region_stats.index, y=region_stats["Count"])
plt.xticks(rotation=45)
plt.title("Number of Annotations by Region")
plt.xlabel("Region")
plt.ylabel("Count")
for i, val in enumerate(region_stats["Percentage"]):
    plt.text(i, region_stats["Count"][i], f"{val}%", ha='center', va='bottom')
plt.show()

# Alternative visualization for plate number length by region
plt.figure(figsize=(12, 6))
sns.violinplot(x=df["region"], y=df["plate_length"])
plt.xticks(rotation=45)
plt.title("Plate Number Length Distribution by Region (Violin Plot)")
plt.xlabel("Region")
plt.ylabel("Plate Number Length")
plt.show()

# Visualization: number of plates with hyphens by region
plt.figure(figsize=(12, 6))
sns.barplot(x=hyphen_stats.index, y=hyphen_stats["Count"])
plt.xticks(rotation=45)
plt.title("Number of Plates with Hyphens by Region")
plt.xlabel("Region")
plt.ylabel("Count")
for i, val in enumerate(hyphen_stats["Percentage"]):
    plt.text(i, hyphen_stats["Count"][i], f"{val}%", ha='center', va='bottom')
plt.show()
