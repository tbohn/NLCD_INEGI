# Processing steps for NLCD_INEGI data

## 1. Harmonization and Rasterization of INEGI Polygon Classifications

This step starts with the Usos del Suelo y Vegetacion SERIE I - V shapefiles.  The procedure for harmonizing the classification schemes of these shapefiles with the NLCD 2011 classification, and converting them to rasters is described in ["Processing_of_INEGI_USOSV_dataset.docx"](./Processing_of_INEGI_USOSV_dataset.docx).

This step requires the ESRI ArcGIS application, and uses arcpy scripts in the "tools/INEGI" directory.

The end result of this step should be ascii-format ESRI raster files, in geographic projection, with cell size of 0.000350884 degrees.

The SERIE_X products correspond to years as follows:
 - SERIE_I: 1985
 - SERIE_II: 1993
 - SERIE_III: 2002
 - SERIE_IV: 2007
 - SERIE_V: 2011

The resulting processed products are available [here](https://zenodo.org/record/2579442).

## 2. Preparation of NLCD Raster Files

Download the following NLCD products from [MRLC](https://www.mrlc.gov/data):
 - NLCD 2011 Land Cover (CONUS)
 - NLCD 2001 Land Cover (CONUS)
 - NLCD 1992 Land Cover (CONUS)
 - NLCD 1992-2001 Land Cover Change Retrofit Product (CONUS)

These products need to be opened in a GIS application such as ESRI ArcGIS, reprojected to geographic, and saved as ascii-format ESRI raster files with cell size of 0.000350884 degrees.

## 3. Processing and Merging of NLCD and INEGI Raster Files

This step uses the scripts and programs in the "tools/NLCD_INEGI" directory.

### 3.1. Download and Compile AscGridTools

The scripts in the `tools/NLCD_INEGI` directory depend on tools from the [`AscGridTools` Git repo](https://github.com/tbohn/AscGridTools). Obtain `AscGridTools` by either forking or cloning the repo, and follow the instructions to compile the tools.

### 3.2. Edit raster files

For all of the INEGI and NLCD rasters, all pixels outside the land/political boundaries should be set to 0, and the "nodata" value in the header should be 0 as well. This can be done in a text editor.

### 3.3. Clip all products to 1x1 degree "tiles"

For each raster file, run the following script:

   `wrap_grid_multi_clip.asc.pl $RASTER int $LAT0 $LAT1 $LON0 $LON1 1 16 0 $DATADIR/$ORGANIZATION/$YEAR/asc.clip.1deg $PREFIX >& log.wrap_grid_multi_clip.asc.pl.txt`

where

 - `$RASTER` = name of the raster file
 - `$LAT0` = the minimum latitude of the raster, rounded down to nearest integer
 - `$LAT1` = the maximum latitude of the raster, rounded up to nearest integer
 - `$LON0` = the minimum longitude of the raster, rounded down to nearest integer
 - `$LON1` = the maximum longitude of the raster, rounded up to nearest integer
 - `$DATADIR` = path to where outputs should be stored (top level)
 - `$ORGANIZATION` = "INEGI" or "NLCD", as appropriate
 - `$YEAR` = 1992, 2001, or 2011 (NLCD); or 1993, 2002, or 2011 (INEGI)
 - `$PREFIX` = "inegi" or "nlcd" as appropriate

### 3.4. Create a more correct version of the NLCD 1992 map

NLCD's 1992 product was created by a different method than later years. To reconcile between 1992 and 2001 maps, NLCD created the 1992/2001 landcover change retrofit product. To make this retrofit product, the more detailed classifications of the 1992 and 2001 products were grouped into 9 broad classes (Anderson level I classification).  The retrofit product therefore shows changes between differetn Anderson Level I classes. This loss of detail poses problems when trying to use the more detailed NLCD 2011 classification scheme.

To retain the more detailed NLCD 2011 classification scheme, we used the retrofit only to identify pixels where changes have occurred. In only those pixels, the classes of the 1992 map replace those of 2001. To perform this step, run:

   `wrap_construct_1992_from_2001_and_retro.pl $DATADIR/NLCD/2001/asc.clip.1deg nlcd $DATADIR/NLCD/1992/asc.clip.1deg nlcd $DATADIR/NLCD/retrofit/asc.clip.1deg nlcd $DATADIR/NLCD/1992.retro/asc.clip.1deg nlcd >& log.wrap_construct_1992_from_2001_and_retro.pl.txt`

where

 - `$DATADIR` = path to where inputs and outputs should be stored (top level)

### 3.5. Combine the NLCD and INEGI 1x1 tiles for each year

Run the command:

   `wrap_grid_overlay.pl $DATADIR/INEGI/$YEAR_I/asc.clip.1deg inegi $DATADIR/NLCD/$YEAR_N/asc.clip.1deg nlcd int 0 16 0 $DATADIR/NLCD_INEGI/$YEAR_OUT/asc.clip.1deg nlcd_inegi >& log.wrap_grid_overlay.pl.txt`

where

 - `$DATADIR` = path to where inputs and outputs should be stored (top level)
 - `$YEAR_I` = year of the INEGI product (1993,2002,2011)
 - `$YEAR_N` = year of the NLCD product (1992,2001,2011)
 - `$YEAR_OUT` = year of the NLCD product (1992,2001,2011)

### 3.6. Create stable_2001-2011 dataset

Run the command:

   `wrap_find_stable_pixels_nlcd_inegi.pl $ROOTDIR $LCYEAR1 $LCYEAR2 >& log.wrap_find_stable_pixels_nlcd_inegi.pl.txt`

where

 - `$ROOTDIR` = `$DATADIR/NLCD_INEGI`
 - `$LCYEAR1` = 2001
 - `$LCYEAR2` = 2011
