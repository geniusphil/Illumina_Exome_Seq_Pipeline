#!/usr/bin/perl
#

$f=$ARGV[0]; ## file list
$out=$ARGV[1]; 

open (IN,$f) || die "can't open the file\n";

@file=<IN>;
chomp @file;

close IN;

$system_call="java -jar ~/bin/picard-tools-1.71/picard-tools-1.71/MergeSamFiles.jar VALIDATION_STRINGENCY=LENIENT OUTPUT=$out";
for(my $i=0; $i<@file; ++$i){
	$system_call = "$system_call INPUT=$file[$i] "; 
}
`$system_call`;

