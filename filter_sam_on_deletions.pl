use strict;
#use warnings;
use Getopt::Std;

my %options=();
getopts("hi:c:v", \%options);

## if help is called program does not continue..
if (exists $options{h}) {print "This pipline is used for the anaylsis of CLIP-seq data using the Zhang Lab CTK software.  It combines a number of programs listed below. None of the operators are required.
	Help:
	usage:  perl filter_sam_on_deletions.x.pl -i some_sam_file.sam
	
	-i input .sam file
	-c cuttoff number of deletions in a sequence aligment
	-h this help screen
	-v verbose\n";
	exit;
}

# Length of deletion allowed in read alignment
my $cutoff = 10;
if (exists $options{c}) {
	$cutoff =$options{c}
}
if (exists $options{v}) {
	print "Cutoff for length of deletion: $cutoff\n";
}

my $input_fh;
my $output_fh;

if (exists $options{i}) {
	open($input_fh, "<", $options{i}) or die "Unable to open input SAM file: $options{i}";
	open($output_fh, ">", "$options{i}.D$cutoff.sam") or die "Unable to open output file: $options{i}.del$cutoff.sam";
 } else {
	print "No input file\n";
	die;
}


# Kill the script if addtional operaters are used
if (exists $ARGV[0]) {
	print "Invalid operators:\n";
	foreach (@ARGV) {
		print "$_\n";
	}
exit;
}

# Open the input SAM file and output file
#open(my $input_fh, "<", "salmon.ivt.CAT.short.sam") or die "Unable to open input SAM file: $!";
#open(my $output_fh, ">", "output.sam") or die "Unable to open output file: $!";

my $countTotal = 0;
my $countRemoved = 0;
my $countprinted = 0;
# Read the input SAM file line by line
while (my $line = <$input_fh>) {
  chomp($line);
	$countTotal++;
  # Add comment and header lines
  if ( $line =~ m/^@/ )
  {print $output_fh "$line\n"; 
	  next;}

  # Split the line into fields
  my @fields = split("\t", $line);

  # Get the CIGAR string
  my $cigar = $fields[5];

  # Parse the CIGAR string to get the length of deletions
 my $deletions = 0;
 while ($cigar =~ /(\d+)D/g) {
	 # Set $deletions great than 1 if deletion is greater than 10
	if ($1 > $cutoff) {
	$deletions = $1;
	if (exists $options{v}) {print $1, "\n";}
	}
}
 if ($deletions > $cutoff) {
	 $countRemoved ++; 
 }
  if ($deletions < $cutoff) {
	 $countprinted++;
 }
 
  # Skip the read if it has a deletion longer than $cuttoff
  next if $deletions > $cutoff;

  # Print the line to the output file
  print $output_fh "$line\n";
}

print "Number of lines: $countTotal\n";
print "Number of lines removed: $countRemoved\n";
print "Number of linee printed: $countprinted\n";


# Close the input and output files
close($input_fh);
close($output_fh);