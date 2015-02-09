#!/usr/bin/perl

package Json2CSVParser;
use strict;
use warnings;
use Exporter;

use List::Util qw(min max);
use Constants qw(parseFileName formatNonIsoDate);
use JSON::XS qw(decode_json encode_json);
use File::Slurp;
use Data::Dumper;
use Test::Simple tests=>1;
use File::Spec;

our @ISA = qw(Exporter);
our @EXPORT = qw(processFile);
our @EXPORT_OK = @EXPORT;

sub processFile {
	my $fileName = $_[0];
	my $errorLogFile = $_[1];
	my $outputDirectory = $_[2];

	eval {
		my %fileChars = parseFileName($fileName);
		my $outputFile = File::Spec->catfile($outputDirectory, "d$fileChars{'recordDate'}.csv");
		my @retVal = parseJsonFile($fileName, $outputFile);

		write_file($outputFile, @retVal);
	};

	if ($@) {
		my @text = read_file($errorLogFile);
		push @text, $fileName . "\n";
		print 'Parsing failed for file' . $fileName . '.';
		write_file($errorLogFile, @text);
	}
}


sub parseJsonFile {
	my $header = "origin,destination,recordtime,price,duration,legs,flightName,seats\n";
	my $fileName = $_[0];
	my $outputFile = $_[1];

	my @arr;
	if (-f $outputFile) {
		@arr = read_file($outputFile);
	} else {
		@arr = qw();
		push @arr, $header;
	}

	my %fileChars = parseFileName($fileName);

	if (scalar(@_) == 2) {
		ok(checkfile($fileName) == 1, 'File ' . $fileName . ' exists. Parsing...');
		my $text = read_file($fileName);
		my $jsonObject = decode_json($text);

		my $flightPrice;

		foreach my $f(@{$jsonObject->{'trips'}->{'tripOption'}}) {
			my $eachLine = "";
			my $flightPrice = $f->{'saleTotal'};
			$flightPrice =~ s/USD//g;
			$eachLine .= $fileChars{'origin'} . ',' . $fileChars{'destination'} . ',' . $fileChars{'recordTime'} . ',' .  $flightPrice . ",";
			foreach my $s(@{$f->{'slice'}}) {
				$eachLine .= $s->{'duration'} . "," . scalar @{$s->{'segment'}} . ",";
				my @carrierNames = qw();
				my @carrierSeatCount = qw();
				my @arrivalTime = qw();
				my @departureTime = qw();

				my $eachCarrier;
				foreach my $seg(@{$s->{'segment'}}) {
					$eachCarrier = $seg->{'flight'}->{'carrier'} . "-" . $seg->{'flight'}->{'number'};
					push @carrierNames, $eachCarrier;
					push @carrierSeatCount, $seg->{'bookingCodeCount'};

					foreach my $leg(@{$seg->{'leg'}}) {
						push @arrivalTime, formatNonIsoDate($leg->{'arrivalTime'});
						push @departureTime, formatNonIsoDate($leg->{'departureTime'});
					}
				}
				$eachLine .= (join(" ", @carrierNames) . "," . min @carrierSeatCount);
				$eachLine .= "\n";
			}
			
			push @arr, $eachLine;
		}
	}

	return @arr;
}


sub checkfile{
	if (-e $_[0]) { return 1;}
	else { return 0; }
}
