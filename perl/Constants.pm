#!/usr/bin/perl

package Constants;
use strict;
use warnings;
use Exporter;
use Time::HiRes qw(time);
use POSIX qw(strftime);
use Keys;

our @ISA = qw(Exporter);

our @EXPORT = qw(mainScript);

our @EXPORT_OK = @EXPORT;

my $baseDirectory = "/Users/rarora/Dropbox/airline/airline-exploration/perl";

sub say {print @_, "\n"}

sub configFile {
	 if (scalar(@_) == 2) {
		return sprintf("%s/config/%s_%s%s", $baseDirectory, $_[0], $_[1], ".json");
	}
}

sub parentFolder {
	my $t = time;
	my $date = strftime "%Y%m%d", gmtime $t;
	my $parentDirectoryName = sprintf("%s/%s", $baseDirectory, $date);
	if (! -d $parentDirectoryName) {
		system ('mkdir', $parentDirectoryName);
	}

	return $parentDirectoryName;
}

sub outputFileName {
	if (scalar(@_) == 2) {
		my $t = time;
		my $date = strftime "%Y%m%d_%H%M%S", gmtime $t;

		my @configFile = split(/\//, configFile($_[0], $_[1]));
		my @configFileName = split(/\./, $configFile[-1]);

		return sprintf("%s/%s_%s_%s.json", parentFolder(), "result", $configFileName[0], $date);
	};
}

sub executeScript {
	if (scalar(@_) == 2) {
		my $curlStatement = "curl -d @";
		my $configFile = configFile($_[0], $_[1]);
		my $tail = " --header \"Content-Type: application/json\" https://www.googleapis.com/qpxExpress/v1/trips/search?key";
		my $api = apiKey();
		my $outputFile = outputFileName($_[0], $_[1]);
		return sprintf("%s%s %s=%s > %s", $curlStatement, $configFile, $tail, $api, $outputFile);
	}
}

sub copyConfigFile {
	if (scalar(@_) == 2) {
		my $originalFile = configFile($_[0], $_[1]);
		my @configFile = split(/\//, $originalFile);

		my $parentFolder = parentFolder();
		my $configFileDirectory = sprintf("%s/%s", $parentFolder, "config");

		if (! -d $configFileDirectory) {
			system('mkdir', $configFileDirectory);
		}
		
		system('cp', $originalFile, sprintf("%s/%s", $configFileDirectory, $configFile[-1]));
	}
}

sub mainScript {
#	my @airports = ("NYC", "SFO", "LAX", "BOS", "MIA", "CHI", "LCY", "DEL", "TYO", "PAR", "PEK", "AUH");
	my @airports = ("NYC", "SFO");
	foreach my $ii(@airports) {
		foreach my $jj(@airports) {
			if ($ii ne $jj) {
				my $executeScript = executeScript($ii, $jj);
				print $executeScript;
				system($executeScript);
				copyConfigFile($ii, $jj);
			}
		}
	}
}
