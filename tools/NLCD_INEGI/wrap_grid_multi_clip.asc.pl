#!/usr/bin/perl

$infile = shift;
$type = shift;
$minlat = shift;
$maxlat = shift;
$minlon = shift;
$maxlon = shift;
$step = shift;
$coord_prec = shift;
$data_prec = shift;
$outdir = shift;
$prefix = shift;

`mkdir -p $outdir`;

for ($lat = $minlat; $lat <= $maxlat; $lat += $step) {
  $lat0 = $lat;
  $lat1 = $lat+$step;
  for ($lon = $minlon; $lon <= $maxlon; $lon += $step) {
    $lon0 = $lon;
    $lon1 = $lon+$step;
    $outfile = "$prefix.$lat0\_$lat1" . "n.$lon0\_$lon1" . "e.asc";
    $cmd = "gridclip $infile $type $lon0 $lon1 $lat0 $lat1 $coord_prec $data_prec $outdir/$outfile";
    print "$cmd\n";
    (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
  }
}
