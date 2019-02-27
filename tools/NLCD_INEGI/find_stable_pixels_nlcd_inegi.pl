#!/usr/bin/perl

$file1 = shift;
$file2 = shift;
$nodata = shift;

open(FILE1,$file1) or die "$0: ERROR: cannot open file $file1 for reading\n";
open(FILE2,$file2) or die "$0: ERROR: cannot open file $file2 for reading\n";
for ($i=0; $i<6; $i++) {
  $line1 = <FILE1>;
  $line2 = <FILE2>;
  print $line1;
}
$row = 0;
foreach $line1 (<FILE1>) {
  $line2 = <FILE2>;
  chomp $line1;
  chomp $line2;
  @fields1 = split /\s+/, $line1;
  @fields2 = split /\s+/, $line2;
  $ncols = @fields1;
  for ($col=0; $col<$ncols; $col++) {
    if ($fields1[$col] eq $fields2[$col]) {
      $class = $fields1[$col];
    }
    else {
      $class = $nodata;
    }
    print "$class";
    if ($col < $ncols-1) {
      print " ";
    }
    else {
      print "\n";
    }
  }
  $row++;
}
close(FILE1);
close(FILE2);
