#!/usr/bin/perl
#

$f=$ARGV[0]; ## vcf file list
$out=$ARGV[1]; ## out merg file

open (IN,$f) || die "Can't open the file\n";

@file=<IN>;
chomp @file;

close IN;

`vcf-merge @file | bgzip -c > $out`;


# for(my $i=0; $i<@file; ++$i){

# 	$system_call = "$system_call $file[$i] "; 

# }

