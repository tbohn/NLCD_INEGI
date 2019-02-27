#!/usr/bin/perl

$dir0 = shift;
$prefix0 = shift;
$dir1 = shift;
$prefix1 = shift;
$type = shift;
$nodata = shift;
$coordprec = shift;
$dataprec = shift;
$outdir = shift;
$outprefix = shift;

`mkdir -p $outdir`;

opendir(DIR,$dir0) or die "$0: ERROR: cannot open dir $dir0 for reading\n";
@files0 = sort grep /^$prefix0/, readdir(DIR);
closedir(DIR);

foreach $file0 (@files0) {
  $file1 = $file0;
  $file1 =~ s/$prefix0/$prefix1/;
  $outfile = $file0;
  $outfile =~ s/$prefix0/$outprefix/;
  $cmd = "grid_overlay $dir0/$file0 $type $dir1/$file1 $type $nodata $type $coordprec $dataprec $outdir/$outfile";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
