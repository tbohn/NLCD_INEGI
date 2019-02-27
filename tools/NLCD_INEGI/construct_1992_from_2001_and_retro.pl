#!/usr/bin/perl

$file_2001 = shift;
$file_1992 = shift; # NLCD 1992 product that used a different method
$file_retro = shift; # NLCD 1992/2001 retrofit change product using Anderson I

%class_conversion = {
  "11" => "11",
  "12" => "12",
  "85" => "21",
  "21" => "22",
  "22" => "23",
  "23" => "24",
  "31" => "31",
  "32" => "31",
  "33" => "31",
  "41" => "41",
  "42" => "42",
  "43" => "43",
  "51" => "52",
  "61" => "82",
  "71" => "71",
  "81" => "81",
  "82" => "82",
  "83" => "82",
  "84" => "82",
  "91" => "90",
  "92" => "95",
}

# Assume all 3 input files have same 6-line header, have same dimensions and
# cover the same exact region
open(FILE2001, $file_2001) or die "$0: ERROR: cannot open $file_2001 for reading\n";
open(FILE1992, $file_1992) or die "$0: ERROR: cannot open $file_1992 for reading\n";
open(FILERETRO, $file_retro) or die "$0: ERROR: cannot open $file_retro for reading\n";
foreach $line_2001 (<FILE2001>) {
  chomp $line_2001;
  @fields_2001 = split /\s+/, $line_2001;
  $line_1992 = <FILE1992>;
  chomp $line_1992;
  @fields_1992 = split /\s+/, $line_1992;
  $line_retro = <FILERETRO>;
  chomp $line_retro;
  @fields_retro = split /\s+/, $line_retro;
  if ($fields_2001[0] =~ /ncols/i) {
    $ncols = $fields_2001[1];
    print "$_\n";
  }
  elsif ($fields_2001[0] =~ /nrows/i) {
    $nrows = $fields_2001[1];
    print "$_\n";
  }
  elsif ($fields_2001[0] =~ /xllcorner/i) {
    $xllcorner = $fields_2001[1];
    print "$_\n";
  }
  elsif ($fields_2001[0] =~ /yllcorner/i) {
    $yllcorner = $fields_2001[1];
    print "$_\n";
  }
  elsif ($fields_2001[0] =~ /cellsize/i) {
    $cellsize = $fields_2001[1];
    print "$_\n";
  }
  elsif ($fields_2001[0] =~ /nodata/i) {
    $nodata = $fields_2001[1];
    print "$_\n";
  }
  else {
    @cout = ();
    for ($col = 0; $col < $ncols; $col++) {
      $c1992 = substr $fields_retro[$col], 0, 1;
      $c2001 = substr $fields_retro[$col], 1, 1;
      if ($c1992 == $c2001) {
        $cout[$col] = $fields_2001[$col];
      }
      else {
        $cout[$col] = $class_conversion{$fields_1992[$col]};
      }
    }
    $line = join " ", @cout;
    print "$line\n";
  }
}
close(FILE2001);
close(FILE1992);
close(FILERETRO);
