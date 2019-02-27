#!/usr/bin/perl

$rootdir = shift;
$lcyear1 = shift;
$lcyear2 = shift;

$indir1 = "$rootdir/$lcyear1/asc.clip.1deg";
$indir2 = "$rootdir/$lcyear2/asc.clip.1deg";
$outdir = "$rootdir/stable_$lcyear1-$lcyear2/asc.clip.1deg";
$prefix = "nlcd_inegi";
$nodata = 0;

`mkdir -p $outdir`;

opendir(DIR,$indir1) or die "$0: ERROR: cannot open dir $indir1 for reading\n";
@files = grep /^$prefix/, readdir(DIR);
closedir(DIR);

foreach $file (sort @files) {
  $cmd = "find_stable_pixels_nlcd_inegi.pl $indir1/$file $indir2/$file $nodata > $outdir/$file";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
