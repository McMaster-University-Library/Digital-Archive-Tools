# Georeferencing guidance for items in the McMaster University Digital Archive
And other handy tools.

# Repository function reference

## gcp_qgis2arc.m
Converts a GCP file in QGIS format to ArcGIS format
Inputs: 
- file_in: The full path to the file (or the filename if in the desired output folder)
- h:   The height of the image (in pixels)
  - Can be pulled from an image using the imagemagick command: identify -quiet -format "%h" <filename>
- r: The resolution of the image (in ppi)
  - Can be pulled from an image using the imagemagick command: identify -quiet -format "%y" <filename>
	
**NOTE** that h and r are optional IF the following conditions are met: 
- A file by the same name as the GCP file (and with a .tif, .tiff, or .jp2 extension) is in the same folder as the GCP file
- ImageMagick is installed on the computer.

## extract_gcps.m
This function uses the gdalinfo command to extract GCP and WKT information from a georeferenced tiff that has an accompanying .aux.xml file. 
inputs: 
- file_in: path to the geotiff. If no path is provided (filename only), script assumes Matlab is in the directory containing the file.
- gdal_path (optional): Allows user to specify the path to the gdal library (often necessary in Windows systems).

**Example inputs and usage:**
```
file_in = 'H:\Digitization_Projects\WWII_Topographic_Maps\LCMSDS\GeoTiff-test\WWIIMMEmden_1945v1_TIFF\WWIIMMEmden_1945v1_TIFF.tif';
gdal_path = 'C:\Program Files\QGIS 3.6\bin';
extract_gcps(file_in, gdal_path)
```

## Georeferencing tutorials 
[QGIS Tutorials georeferencing tutorial](https://www.qgistutorials.com/en/docs/georeferencing_basics.html)

## Working with Coordinate Reference Systems (CRS)
- Guide: [Working with projections in QGIS](https://docs.qgis.org/3.4/en/docs/user_manual/working_with_projections/working_with_projections.html)
- Guide: [Working with a custom CRS in QGIS](https://docs.qgis.org/3.4/en/docs/user_manual/working_with_projections/working_with_projections.html#custom-coordinate-reference-system)

## Converting QGIS GCP files to ArcGIS format
 
### Default QGIS format convention
- Origin is located at the top-left of the image
- GCP file is a text-based, comma-separated file with an extension <image_name>.tif.points
- GCP file contains a header and has five columns: mapX,mapY,pixelX,pixelY,enable
  - mapX = horizontal location of point in a pre-defined Coordinate Reference System (e.g. Longitude, Easting)
  - mapY = vertical location of point in a pre-defined Coordinate Reference System (e.g. Latitude, Northing)
  - pixelX = horizontal location of point in the image, measured in units of pixels from the origin. PixelX increases to the right of the image
  - pixelY = vertical location of point in the image, measured in units of pixels from the origin. PixelY decreases toward the bottom of the image (i.e. all y values are <=0)
  - enable = flag to indicate whether a point should be used in georeferencing operation (0 = disabled / not used; 1 = enabled / used)
  
### Default ArcGIS format convention
- Origin is located at the bottom-left of the image
- GCP file is a text-based, tab-delimited file with an extension <image_name>.txt
- GCP file has no header and four columns
  - column1 = horizontal location of point in the image, measured in units of inches from the origin (comparable to PixelX in QGIS format). Value increases to the right of the image.
  - column2 = vertical location of point in the image, measured in units of inches from the origin (comparable to PixelY in QGIS format). PixelY increases toward the top of the image (i.e. all y values are >=0)
  - column3 = horizontal location of point in a pre-defined Coordinate Reference System (e.g. Longitude, Easting). Comparable to MapX in QGIS format
  - column4 = vertical location of point in a pre-defined Coordinate Reference System (e.g. Latitude, Northing). Comparable to MapY in QGIS format

### Default GDAL format convention
- Origin is located at the bottom-left of the image. 
  - pixelX = horizontal location of point in the image, measured in units of pixels from the origin. PixelX increases to the right of the image
  - pixelY = vertical location of point in the image, measured in units of pixels from the origin. PixelY increases toward the bottom of the image (i.e. all y values are >=0)
  - mapX = horizontal location of point in a pre-defined Coordinate Reference System (e.g. Longitude, Easting)
  - mapY = vertical location of point in a pre-defined Coordinate Reference System (e.g. Latitude, Northing)    
- i.e. format is the same as QGIS, except that columns are structured in a different order and sign on PixelY is reversed.

### Converting from QGIS to ArcGIS format
Required information / materials: 
- GCP file in QGIS format
- h = Height of the image in pixels
- r = Resolution of the image (in points per inch)

The output ArcGIS file can be created from the QGIS file columns as: 

```pixelX/r	(pixelY+h)/r	mapX	mapY```, where columns are tab-delimited

### Converting ArcGIS to QGIS format
Required information / materials: 
- GCP file in ArcGIS format
- h = Height of the image in pixels
- r = Resolution of the image (in points per inch)
- header written to top of target file: mapX,mapY,pixelX,pixelY,enable

The output QGIS file can be created from the ArcGIS file columns as: 

```column3, column4, column1*r, (column2*r)-h (where columns are comma-delimited)```

### Extracting height and resolution information from an image
Height (h) and resolution (r) can be extracted from an image programatically using the following imageMagick commands: 
- for height: ```identify -quiet -format "%h" <filename>```
- for resolution: ```identify -quiet -format "%y" <filename>```