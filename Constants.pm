#!/usr/bin/perl

package Constants;
use strict;
use warnings;
use Exporter;
use Time::HiRes qw(time);
use POSIX qw(strftime);
use Keys;

our @ISA = qw(Exporter);

our @EXPORT = qw(executeScript copyConfigFile);

our @EXPORT_OK = @EXPORT;

sub configFile {
	return "query.json";
}

sub parentFolder {
	my $baseDirectory = '/Users/rarora/Dropbox/airline/airline-exploration/data';
	my $t = time;
	my $date = strftime "%Y%m%d", gmtime $t;
	my $parentDirectoryName = sprintf("%s/%s", $baseDirectory, $date);
	if (! -d $parentDirectoryName) {
		system ('mkdir', $parentDirectoryName);
	}

	return $parentDirectoryName;
}

sub outputFileName {
	my $t = time;
	my $date = strftime "%Y%m%d_%H%M%S", gmtime $t;
	my @configFile = split(/\./, configFile());

	return sprintf("%s/%s_%s_%s.json", parentFolder(), "result", $date, $configFile[0]);
}

sub executeScript {
	my $curlStatement = "curl -d @";
	my $configFile = configFile();
	my $tail = " --header \"Content-Type: application/json\" https://www.googleapis.com/qpxExpress/v1/trips/search?key";
	my $api = apiKey();
	my $outputFile = outputFileName();
	return sprintf("%s%s %s=%s > %s", $curlStatement, $configFile, $tail, $api, $outputFile);
}

sub copyConfigFile {
	my $configFile = configFile();
	my $parentFolder = parentFolder();
	my $configFileDirectory = sprintf("%s/%s", $parentFolder, "config");

	if (! -d $configFileDirectory) {
		system('mkdir', $configFileDirectory);
	}
	
	system('cp', $configFile, sprintf("%s/%s", $configFileDirectory, $configFile));
}
