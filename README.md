# NLCD_INEGI: Harmonized US-Mexico Land Cover Classifications from NLCD and INEGI, 1992/2001/2011

This project contains scripts used to created harmonized US-Mexico land cover classifications for years 1992, 2001, and 2011.

## Processing stages:
1. Harmonize the original INEGI Uso del Suelo y Vegetacion classifications (for the Mexican portion of the domain) with the NLCD classifications, and rasterize them.
..* Inputs: the INEGI Uso del Suelo y Vegetacion classifications, SERIE I - V, which represent years 1985, 1993, 2002, 2007, and 2011.
..* Outputs: the outputs are archived on [Zenodo](https://www.zenodo.org/record/2579442).
2. Merge the harmonized INEGI rasters with the NLCD products for complete coverage over the US and Mexico.
..* Inputs: For Mexico, use the output of stage 1 (either run stage 1 or download outputs from [Zenodo](https://www.zenodo.org/record/2579442).). For the continental US, the NLCD land cover products for years 1992, 2001, and 2011, plus the NLCD 1992/2001 land cover change retrofit product, available from [MRLC](https://www.mrlc.gov/data).
..* Outputs: the outputs are archived on [Zenodo](https://www.zenodo.org/record/2580428)

## Contents:
1. tools/
 - INEGI/ - arcPy scripts for stage 1, i.e., harmonizing the INEGI Uso del Suelo y Vegetacion classifications with the NLCD 2011 classification categories, reprojecting to geographic, and rasterizing.
 - NLCD_INEGI/ - tools written in C and Perl for stage 2, i.e., constructing an NLCD 1992 product consistent with the classifications of NLCD 2001 and 2011, and for merging the NLCD maps with the INEGI maps.
2. docs/
 - [Processing_of_INEGI_USOSV_dataset.docx](docs/Processing_of_INEGI_USOSV_dataset.docx) - Description of procedure for harmonizing the INEGI Uso del Suelo y Vegetacion classifications with the NLCD 2011 classification categories, reprojecting to geographic, and rasterizing.
 - [Processing_NLCD_INEGI.md](docs/Processing_NLCD_INEGI.md) - Description of procedure for constructing an NLCD 1992 product consistent with the classifications of NLCD 2001 and 2011, and for merging the NLCD maps with the INEGI maps.
