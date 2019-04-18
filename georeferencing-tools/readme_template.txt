# Introduction
The georeferencing files made available through the digital archive contain resources to georeference the original image using QGIS software. Contents include: 

- Ground control point (GCP) file [macrepo_<macrepo>.tiff.points] necessary to georeference this map using QGIS
- This readme file [macrepo_<macrepo>_README.txt], which contains coordinate reference system information and instructions on how to georeference the downloaded original image [TIFF or JPEG2000]
- ISO 19115 metadata file [macrepo_<macrepo>_ISO19115.xml], which provides additional geospatial metadata. Note that this file may not be included in all packages.

# Coordinate reference system (CRS) information
- The GCP file [macrepo_<macrepo>.tiff.points] that is provided in this package is formatted for QGIS software. More information on converting to other software formats (e.g. ArcGIS) can be found at https://github.com/maclibGIS/Digital-Archive-Tools/blob/master/georeferencing-tools/
- Ground control points (GCPs) have been created in the CRS defined by <CRS>.
- Find more information on setting and using CRS in QGIS software at https://github.com/maclibGIS/Digital-Archive-Tools/blob/master/georeferencing-tools/

# Using the GCP file to georeference the original image
- Guidance can be found at https://github.com/maclibGIS/Digital-Archive-Tools/blob/master/georeferencing-tools/

# Disclaimer
- The files included in this package and the information within are made available to the user on an as-is basis. While the contents of this package have been curated, we make no guarantees about their overall accuracy or utility.

# License
- All materials in this package are licensed under a Creative Commons Attribution-NonCommercial 2.5 License (http://creativecommons.org/licenses/by-nc/2.5/ca/).