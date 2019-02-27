#!/usr/bin/perl

$dir_2001 = shift;
$prefix_2001 = shift;
$dir_1992 = shift;
$prefix_1992 = shift;
$dir_retro = shift;
$prefix_retro = shift;
$outdir = shift;
$outprefix = shift;

`mkdir -p $outdir`;

opendir(DIR,$dir_2001) or die "$0: ERROR: cannot open dir $dir_2001 for reading\n";
@files_2001 = sort grep /^$prefix_2001/, readdir(DIR);
closedir(DIR);

foreach $file_2001 (@files_2001) {
  $file_1992 = $file_2001;
  $file_1992 =~ s/$prefix_2001/$prefix_1992/;
  $file_retro = $file_2001;
  $file_retro =~ s/$prefix_2001/$prefix_retro/;
  $outfile = $file_2001;
  $outfile =~ s/$prefix_2001/$outprefix/;
  $cmd = "construct_1992_from_2001_and_retro.pl $dir_2001/$file_2001 $dir_1992/$file_1992 $dir_retro/$file_retro > $outdir/$outfile";
  print "$cmd\n";
  (system($cmd)==0) or die "$0: ERROR: $cmd failed\n";
}
