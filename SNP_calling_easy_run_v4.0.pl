#!/usr/bin/perl -w

##
## SNP Calling easy run version 4.0 
## stage3_pipe
## Edit: Philippe
## Date: August.22.2012
## Update: Jan.17.2013
## @Description SNP Calling script for GATK
## BWA sampe include Read Group
## Calling Tools: samtools, bcftools, samstat and GATK
##

use Getopt::Std;

sub Usage{
    print STDERR <<EOF;
    BWA easyrun script
    
    -r reference
    -b bam file prefix
    -h Help
    
EOF
    exit;
}
my %opt;
getopt("r:b:h:", \%opt);
my $ref = $opt{r} or &Usage();
my $prefix = $opt{b} or &Usage();
$opt{h} and &Usage();

## GATK SNP Calling
##
## Picard tools 
#`java -jar ValidateSamFile.jar INPUT=/mnt/qnap1/tmpPapalynn/bwa/541N.sorted.bam`;

## Run GATK
##
## Check Reads, Loci, and Coverage
#`java -jar /home/yhlin/bin/GenomeAnalysisTK-2.0-39-gd091f72/GenomeAnalysisTK.jar -T CountReads -R /home/papalynn/hg19.fasta $prefix.gatk.realigned.bam -I 541N.sorted.bam`; 
#`java -jar /home/yhlin/bin/GenomeAnalysisTK-2.0-39-gd091f72/GenomeAnalysisTK.jar -T CountLoci -R /home/papalynn/hg19.fasta -I 541N.sorted.bam -o output.txt`;
#`java -jar /home/yhlin/bin/GenomeAnalysisTK-2.0-39-gd091f72/GenomeAnalysisTK.jar -T CoverageBySample -R /home/papalynn/hg19.fasta -I 541N.sorted.bam -o coverage.txt -L chr1:1-200`;

## Mapping Bam file index and stat
`samtools index "$prefix"_bwa.bam`;
`samtools flagstat "$prefix"_bwa.bam > "$prefix"_bwa.bam.stat`;

## GATK Realigner Target Creator
`java -jar ~/bin/GenomeAnalysisTK-2.3-5-g49ed93c/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $ref -I "$prefix"_bwa.bam -o $prefix.intervals`;
## GATK Indel Realigner
`java -jar ~/bin/GenomeAnalysisTK-2.3-5-g49ed93c/GenomeAnalysisTK.jar -T IndelRealigner -R $ref -I "$prefix"_bwa.bam -targetIntervals $prefix.intervals -o $prefix.realigned.bam`;

## Picard Make duplicates
`java -jar ~/bin/picard-tools-1.71/picard-tools-1.71/MarkDuplicates.jar I=$prefix.realigned.bam O=$prefix.realigned.rmdup.bam METRICS_FILE=$prefix.duplicate_report.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true ASSUME_SORTED=true`;

## 
`samtools index $prefix.realigned.rmdup.bam`;
`samtools flagstat $prefix.realigned.rmdup.bam > $prefix.realigned.rmdup.bam.stat`;

## SAMStat (output html file)
`samstat $prefix.realigned.rmdup.bam`;

## GATK BaseRecalibrator
`java -jar ~/bin/GenomeAnalysisTK-2.3-5-g49ed93c/GenomeAnalysisTK.jar -T BaseRecalibrator -R $ref -I $prefix.realigned.rmdup.bam -knownSites ../dbsnp_sort.vcf -o $prefix.recal_data.grp`;

## GATK Print Reads
`java -jar ~/bin/GenomeAnalysisTK-2.3-5-g49ed93c/GenomeAnalysisTK.jar -T PrintReads -R $ref -I $prefix.realigned.rmdup.bam -BQSR $prefix.recal_data.grp -o $prefix.realigned.rmdup.recali.bam`;

## GATK Unified Genotype
`java -jar ~/bin/GenomeAnalysisTK-2.3-5-g49ed93c/GenomeAnalysisTK.jar -T UnifiedGenotyper -R $ref -I $prefix.realigned.rmdup.recali.bam -o "$prefix"_gatk.vcf -stand_call_conf 30.0 -stand_emit_conf 10.0 -glm both -D ../dbsnp_sort.vcf`;

## SAMtools mpileup
`samtools mpileup -ugf $ref $prefix.realigned.rmdup.recali.bam | bcftools view -bcvg - > $prefix.samtools.var.raw.bcf`;
`bcftools view $prefix.samtools.var.raw.bcf | vcfutils.pl varFilter -D 500 > "$prefix"_samtools.vcf`;


print STDERR "************\n";
print STDERR "Finished!!!!\n";
