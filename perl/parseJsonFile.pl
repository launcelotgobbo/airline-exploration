#!/usr/bin/perl

use strict;
use warnings;
use Json2CSVParser;
use Data::Dumper;
use File::Basename;
use File::Spec;
use File::Touch;
use Constants qw(parseFileName);

my $errorLogFile = '/Users/rarora/data/qpx/perl/error.txt';
my $parentDirectory = '/Users/rarora/data/qpx/perl/';
my @fileFolders = `ls $parentDirectory | grep 20150208`;
my $parseFileLocation = '/Users/rarora/data/qpx/perl/csv/';

foreach my $currFolder(@fileFolders) {
	
	chomp(my $currentDirectory = File::Spec->catdir($parentDirectory, $currFolder));
	if (-d $currentDirectory){
		opendir(DIR, $currentDirectory) or die "Can't open directory";
		while (readdir DIR) {
			my $fileName = "$currentDirectory/$_";
			if (-f $fileName) {
				my ($name,$path,$suffix) = fileparse($fileName, ".json");
				if ($suffix eq ".json") {
					my %fileChars = parseFileName($fileName);
					my $targetDirectory = File::Spec->catdir($parseFileLocation, "$fileChars{'origin'}_$fileChars{'destination'}");
					if (!-d $targetDirectory) {
						system(`mkdir $targetDirectory`);
					}

					processFile($fileName, $errorLogFile, $targetDirectory);
				}
			}
		}
		closedir(DIR);
	}
}

# processFile($processFile, $errorLogFile, '');
# my $processFile = $parentDirectory . $currFileName;
