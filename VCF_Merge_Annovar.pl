#!/usr/bin/perl
#
#

$f=$ARGV[0]; ## vcf file list
$out=$ARGV[1]; ## out merg file

open (IN,$f) || die "Can't open the file\n";

@file=<IN>;
chomp @file;

close IN;

# use vcf-merge
`vcf-merge @file | bgzip -c > $out`;

# use annovar convert to annovar format
`convert2annovar.pl -format vcf4 --includeinfo $out > "$out".avinput`;

# use annovar summarize
`summarize_annovar.pl -buildver hg19 --verdbsnp 137 --ver1000g 1000g2012apr --veresp 6500 --genetype knowngene --outfile /mnt/mibNGS/ "$out".avinput /opt/annovar_2013feb11/humandb/`;

