#!/usr/bin/perl

$lu_map = shift; # land use map; name must end with .resolution_deg.asc
$minlat = shift;
$maxlat = shift;
$minlon = shift;
$maxlon = shift;
$nodata_lu = shift;
$lu_codes_table = shift;
$nlcd_map = shift;
$lu_map_out = shift;

# Subsample land cover map to nlcd resolution
$lu_map_sub = $lu_map;
$lu_map_sub =~ s/\.([\d\.]+_deg).asc$/.0.000350884_deg.asc/;
$cmd = "grid_subsample $lu_map int 0.0003508840696170 nn 0 int 16 0 tmp.asc";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
$cmd = "gridclip tmp.asc int $minlon $maxlon $minlat $maxlat 16 0 $lu_map_sub";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

# Make NLCD urban mask
$cmd = "grid_make_mask_thresh $nlcd_map int gt 20 16 tmp.asc";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
$cmd = "grid_make_mask_thresh $nlcd_map int lt 30 16 tmp2.asc";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
$nlcd_urban_mask = $nlcd_map;
$nlcd_urban_mask =~ s/.asc$/.urban_mask.asc/;
$cmd = "grid_apply_mask tmp.asc int tmp2.asc 16 0 $nlcd_urban_mask";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

# Read lc codes table
open(FILE, $lu_codes_table) or die "$0: ERROR: cannot open lu codes table $lu_codes_table for reading\n";
foreach (<FILE>) {
  if (/^#/) {next;}
  chomp;
  @fields = split /,/;
  if ($fields[2] =~ /null/i) {
    $null{$fields[0]} = 1;
  }
  elsif ($fields[2] =~ /mix/i) {
    $mixed{$fields[0]} = 1;
  }
  elsif ($fields[2] ne "") {
    $replace{$fields[0]} = $fields[2];
  }
}
close(FILE);

# Add 100 to lu map codes
$lu_map_plus100 = $lu_map_sub;
$lu_map_plus100 =~ s/.asc$/.plus100.asc/;
$cmd = "grid_math $lu_map_sub int 100 const + $nodata_lu int 0 16 0 $lu_map_plus100";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

$cmd = "cp $lu_map_plus100 tmp.asc";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

# Replace some of the classes in the lu map
foreach $code (sort(keys(%replace))) {
  $code_in = $code + 100;
  $cmd = "grid_paint_values.pl tmp.asc -90 90 -180 180 eq $code_in 0 $replace{$code} > tmp2.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  $cmd = "mv tmp2.asc tmp.asc";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}

# Null out some of the classes in the lu map
$info = `grep nodata tmp.asc`;
chomp $info;
@fields = split /\s+/, $info;
$nodata_orig = $fields[1];
foreach $code (sort(keys(%null))) {
  $code_in = $code + 100;
  $cmd = "grid_paint_values.pl tmp.asc -90 90 -180 180 eq $code_in 0 $nodata_orig > tmp2.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  $cmd = "mv tmp2.asc tmp.asc";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}

# Handle mixed classes
foreach $code (sort(keys(%mixed))) {
  $code_in = $code + 100;
  # Clip out NLCD non-developed pixels from this class in the lu_map
  $cmd = "grid_make_mask_thresh tmp.asc int eq $code_in 16 mask.$code.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  $cmd = "grid_apply_mask mask.$code.asc int $nlcd_urban_mask 16 0 mask.$code.masked_nlcd_urban.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  $cmd = "grid_math mask.$code.masked_nlcd_urban.asc int $code_in const \"*\" $nodata_orig int 0 16 0 map.$code.masked_nlcd_urban.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  # Null out this class from the lu_map
  $cmd = "grid_paint_values.pl tmp.asc -90 90 -180 180 eq $code_in 0 $nodata_orig > tmp2.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  $cmd = "mv tmp2.asc tmp.asc";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  # Overlay the clipped map of this class on top of the lu_map
  $cmd = "grid_overlay map.$code.masked_nlcd_urban.asc int tmp.asc int $nodata_orig int 16 0 tmp2.asc";
print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  $cmd = "mv tmp2.asc tmp.asc";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}

## Ensure that nodata is the value we want
#$cmd = "grid_paint_values.pl tmp.asc -90 90 -180 180 eq $nodata_orig 1 $nodata_lu > tmp2.asc";
#print "$cmd\n";
#(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
#$cmd = "mv tmp2.asc tmp.asc";
#(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

# Final nulled map
$lu_map_nulled = $lu_map_sub;
$lu_map_nulled =~ s/.asc$/.nulled.asc/;
$cmd = "mv tmp.asc $lu_map_nulled";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";

# Overlay nulled map on top of nlcd map
$cmd = "grid_overlay $lu_map_nulled int $nlcd_map int $nodata_lu int 16 0 $lu_map_out";
(system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
