# Processing steps for hybrids of NLCD_INEGI and other classifications

## Overview
We have encountered several cases in which we want to investigate the impacts of projected future land use changes.  The projections are usually supplied by land use maps that of necessity focus on anthropogenic land covers/uses. These classifications classify land covers primarily by their uses (e.g., "industrial") or ownership (e.g., "military", "institutional", "natural"). But for modeling purposes, we need to know primarily the physical characteristics, such as average height, roughness length, presence/absence of overstory, stomatal resistance parameters, etc. Thus, "natural" is not descriptive enough; it is crucial to distinguish among classes such as open shrublands, grasslands, deciduous broadleaf forests, and evergreen needleleaf forests. A pure land cover map derived from remote sensing, such as NLCD_INEGI, would be more useful in this regard. However, few satellite-based land cover maps exist that have accompanying projections of future land cover.

Thus, in this situation, we would like to take the best features of each classification: where anthropogenic classes are projected to change, the change will be captured via the historical and projected land use maps; but areas that are "natural" are characterized by the more phyiscally meaningful land cover map (e.g., NLCD_INEGI) assuming we neglect changes in vegetation due to climate change.

The procedure for merging these two types of maps amounts to identifying the classes that we care about from the land use map and overlaying them (without the other classes) on top of the land cover map.

## 1. Preparation of the Historical and/or Future Land Use Maps

All of the land cover/use maps must have the same file format; the scripts described here assume that the files are ascii-format ESRI grid files. ESRI's ArcGIS can be used to convert shapefiles and other formats to ascii grid files.

The NLCD_INEGI land cover classification can be downloaded from [Zenodo](https://www.zenodo.org/record/2591501).

## 2. Preparation of Land Use Table

The scripts described here also require a table enumerating the historical or future land use classes, along with instructions on how to treat them when generating the hybrid map. The table must be an ascii comma-separated-value (csv) file, with the following format:

   `Code,Group,Name,Comment,`

where
 - `Code` = numeric land use class code
 - `Group` = super-category of land use; values are ignored in this step
 - `Name` = name of the specific land use class
 - `Comment` = can be one of:
   - `nulled` = replace pixels of this class with the NLCD_INEGI (or other) land cover classification
   - `mix` = pixels of this class are replaced where NLCD_INEGI (or other) classification assigns them to a natural class
   - anything else, or blank = pixels of this class retain their class

An example land use table can be found in [examples/Codes.ICLUS.csv](examples/Codes.ICLUS.csv).

## 3. Merging of the Land Use and NLCD_INEGI (or Other) Land Cover Classifications

This step uses the scripts and programs in the "tools/hybrid" directory.

### 3.1. Download and Compile AscGridTools

The scripts in the `tools/NLCD_INEGI` directory depend on tools from the [`AscGridTools` Git repo](https://github.com/tbohn/AscGridTools). Obtain `AscGridTools` by either forking or cloning the repo, and follow the instructions to compile the tools.

### 3.2. Clip the Historical and Future Land Use Maps to the Same Domain as the NCLD (or Other) Land Cover Maps

The NLCD_INEGI classification is divided into many 1x1 degree "tiles". If you plan on using NLCD_INEGI, you either need to mosaic these tiles back together over your domain of interest, or clip the historical/future land use files to the same set of 1x1 degree tiles.

To clip the land use maps to 1x1 tiles, run:

   `wrap_grid_multi_clip.asc.pl $RASTER int $LAT0 $LAT1 $LON0 $LON1 1 16 0 $DATADIR/$PRODUCT/asc.clip.1deg $PREFIX >& log.wrap_grid_multi_clip.asc.pl.txt`

where

 - `$RASTER` = name of the raster file
 - `$LAT0` = the minimum latitude of the raster, rounded down to nearest integer
 - `$LAT1` = the maximum latitude of the raster, rounded up to nearest integer
 - `$LON0` = the minimum longitude of the raster, rounded down to nearest integer
 - `$LON1` = the maximum longitude of the raster, rounded up to nearest integer
 - `$DATADIR` = path to where outputs should be stored (top level)
 - `$PRODUCT` = name of the land use map product, plus any other distinguishing information such as the year or land use scenario that this map describes
 - `$PREFIX` = an appropriate file prefix (output files will be named by `$PREFIX.$LATLON.asc`, where `$LATLON` is a string describing the boundaries of the 1x1 tile)

### 3.3. Do the Merge

The merge consists of the following steps (all of which are handled by a single script):
 1. subsample the historical or future land use map to the same resolution as the NLCD_INEGI classifications
 2. for pixels that have class codes indicated as "nulled" in the land use table, replace their class with the nodata value
 3. create a mask from the NLCD_INEGI file where 1 = pixel is one of the NLCD_INEGI urban classes and 0 = pixel is some other non-urban class
 4. for pixels that have class codes indicated as "mix" in the land use table, replace their class with the nodata value **if** the NLCD_INEGI urban mask is 0 for that pixel
 5. add 100 to the land use map class codes (to ensure no conflicts between land use codes and NLCD_INEGI land cover codes)
 6. overlay this modified land use map on top of the NLCD_INEGI map; where the land use map pixels were replaced with nodata values, the NLCD_INEGI pixel classes will be used

For each 1x1 tile (or for a single file containing the domain of interest): run the following script:

   `process_urban_lu_map.pl $LAND_USE_FILE $LAT0 $LAT1 $LON0 $LON1 $NODATA_LU $LU_CODES_TABLE $NLCD_FILE $LAND_USE_FILE_OUT >& log.process_urban_lu_map.pl.txt`

where

 - `$LAND_USE_FILE` = name of the historical or future land use file file
 - `$LAT0` = the minimum latitude of the file
 - `$LAT1` = the maximum latitude of the file
 - `$LON0` = the minimum longitude of the file
 - `$LON1` = the maximum longitude of the file
 - `$NODATA_LU` = the value used in `$LAND_USE_FILE` to indicate missing values
 - `$LU_CODES_TABLE` = name of the land use codes table prepared in step 2.
 - `$NLCD_FILE` = name of the NLCD_INEGI (or other) land cover file
 - `$LAND_USE_FILE_OUT` = desired output file name
