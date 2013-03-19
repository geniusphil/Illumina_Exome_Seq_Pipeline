#!/usr/bin/perl -w

##
## BWA easy run version 2.0
## Edit: Philippe
## Date: August.21.2012
## @Description bwa alignment script
## BWA sampe include Read Group
## SNP calling use <SNP_calling_easy_run_v1.0.pl>
##

use Getopt::Std;

sub Usage{
    print STDERR <<EOF;
    BWA easyrun script

    -r reference sequence
    -1 read 1
    -2 read 2
    -o output prefix
    -g RG
    -i head RG ID (Read Group Identifier)
    -m head RG SM (Read Group Sample)
    -l head RG LB (Read Gropu Library)
    -p head RG PL (Read Group Platform)
    -b path to bwa and samtool (default: ~/bin)
    -h help
EOF
    exit;
}
my %opt;
getopt("r:1:2:h:o:b:g:i:m:l:p:", \%opt);
my $ref = $opt{r} or &Usage();
my $read1 = $opt{1} or &Usage();
my $read2 = $opt{2} or &Usage();
my $prefix = $opt{o} or &Usage();
my $rg = $opt{g} or &Usage();
my $rgID = $opt{i} or &Usage();
my $rgSM = $opt{m} or &Usage();
my $rgLB = $opt{l} or &Usage();
my $rgPL = $opt{p} or &Usage();
$opt{h} and &Usage();

my $read1_name = `basename $read1`;
my $read2_name = `basename $read2`;
chomp($read1_name);
chomp($read2_name);
my $read1_sai = $read1_name . ".sai";
my $read2_sai = $read2_name . ".sai";
#my $PATH = '~/bin';
#defined $opt{b} and $PATH = $opt{b};

print STDERR "ref:$ref\tread1:$read1\tread2:$read2\toutput prefix:$prefix\tRG:$rg\tID:$rgID\tSM:$rgSM\tPL:$rgPL\n";
## BWA alignment
#`bwa index $ref`;
`bwa aln -t 8 $ref $read1 > $read1_sai `;
`bwa aln -t 8 $ref $read2 > $read2_sai`;
`bwa sampe -r '$rg\tID:$rgID\tSM:$rgSM\tLB:$rgLB\tPL:$rgPL' $ref $read1_sai $read2_sai $read1 $read2 > $prefix.sam`;

# SAMTools (sam file to bam file and sorting)
#`samtools view -S $prefix.sam -b -o $prefix.bam`;
#`samtools sort $prefix.bam $prefix.bam.sorted`;
#`samtools index $prefix.bam.sorted.bam`;
#`samtools flagstat $prefix.bam.sorted.bam > $prefix.bam.sorted.bam.stat`;

## SAMStat
#`samstat $prefix.bam.sorted.bam`;

# remove file, fastq, sai, and sam
print STDERR "*******************\n";
print STDERR "Remove: Align file: $read1_sai\t$read2_sai\tSAM file:$prefix.sam\tPairEnd";
print STDERR "*******************\n";
`rm $read1_sai $read2_sai`;
#`rm $prefix.sam`;
#`rm $prefix.bam`;
`echo $prefix.sam >> bamlist.txt`;
print STDERR "************\n";
print STDERR "Finished!!!!\n";


#@description   modify qualty score in sam file from Illumina quality to Sanger Qualty
#
#@obsoleted
sub sam_qualty_modify
{
    my $fn = shift;
    open FR, $fn or die;
    open FW , "> $fn.m" or die;

    my $header = <FR>;
    print FW "$header";

    while(<FR>){
    @tmp=split;
    @qual = split //, $tmp[10];
    foreach my $q (@qual){
        $tmp[10] = chr(ord($q)-31);
    }
    print FW "@tmp\n";
    }
    close FR;
    close FW;
}
