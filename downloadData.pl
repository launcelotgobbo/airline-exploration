#!/usr/bin/perl

use strict;
use warnings;
use Constants;

my $executeScript = executeScript();
system($executeScript);

copyConfigFile();
