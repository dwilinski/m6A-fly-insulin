use strict;
use Getopt::Std;

my %repeats_hash;
my @fastq_array;
my $numberofreads=0;
my $numberofoutputreads=1;
my %fastq_hash;

#my $fastqfilename = "DW013.fastqsanger";
#my $outfile = "DW013_repeats_rm.fastqsanger";

#####################################
### Command line arguments 
####################################
my %options=();
getopts("hi:I:", \%options);

## if help is called program does not continue..
if (exists $options{h}) {print "This script removes duplicated reads from a fastq file based on the first x bases.
	Help:
	usage:  perl reomve_duplicated_reads_from_fastqNEW.pl -i
	
	-i input fastq file name (read 1)
	-I input fastq file name (read 2)
	-v verbose\n";
	exit;
};


if (exists $options{i}) {
	print "Forward reads file (fastq):\n";
	print $options{i}, "\n";
}
else { die "No input file\n"; }

if (exists $options{I}) {
	print "Reverse reads file (fastq):\n";
	print $options{I}, "\n";
}

##### end command line inputs


my $fastqfilename = $options{i};


#print "What is the name of the file with dipulicates to remove?";
#chomp( $fastqfilename = <STDIN> );
my $outfile = "$fastqfilename\_duplicates_rmvd.fastq";


#####################
##this routine opens the fastq file and writes it to an array @fastq_array.

open (FASTQ, $fastqfilename) || die "Can't open $fastqfilename\n";

my $fastqcount=0;
while (my $line = <FASTQ>) {
 chomp $line;

if ($fastqcount < 4) {
 $fastq_array[$numberofreads][$fastqcount] = $line;
 $fastqcount++;
 }

if ($fastqcount eq 4)
 {
 $fastqcount=0;
 $numberofreads++;
 }

#print $fastqcount, "\t", $numberofreads, "\n"; 

}

close (FASTQ);
print "Read $fastqfilename into array\n";


#######################
##This routine sorts the @fastq_array based on the squence position one of the array (ID, sequence, +, quality score).

@fastq_array = sort { $a->[1] cmp $b->[1] } @fastq_array;
print "Sorted array\n";


#######################
##The routine prints only the unique sequences.  Since all the reads should have random bar codes any sequence that is
##identical is removed.  It should not be necessary to first align the sequences.  Although this will be slower. 

open (OUTFILE, ">$outfile") || die "Can't open $outfile\n";

 print OUTFILE $fastq_array[0][0], "\n"; 	###this keeps the first row no matter what b/c there is nothing to compare it to
 print OUTFILE $fastq_array[0][1], "\n";
 print OUTFILE $fastq_array[0][2], "\n";
 print OUTFILE $fastq_array[0][3], "\n";

for (my $i=1;$i<$numberofreads;$i++) {
 if (substr($fastq_array[$i][1], 0, 20) ne substr($fastq_array[$i-1][1], 0, 20))   ####this only compares the first 20 bases
  { 
   print OUTFILE $fastq_array[$i][0], "\n";
   print OUTFILE $fastq_array[$i][1], "\n";
   print OUTFILE $fastq_array[$i][2], "\n";
   print OUTFILE $fastq_array[$i][3], "\n";
	$numberofoutputreads++;
  }

}

close (OUTFILE);

print "Number of reads: $numberofreads\n";
print "Number of duplicate reads:", $numberofreads-$numberofoutputreads," (", ($numberofreads-$numberofoutputreads)/$numberofreads*100,"%)", "\n";
print "Number of reads not duplicated: $numberofoutputreads (",$numberofoutputreads/$numberofreads*100  ,"%)\n";  