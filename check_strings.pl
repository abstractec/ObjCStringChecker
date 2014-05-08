#!/usr/bin/perl
use strict;
use warnings;

sub read_dir {
  my $dir = $_[0];

  opendir (DIR, $dir) or die $!;

  my @directories;

  while (my $file = readdir(DIR)) {
    next if ($file =~ m/^\./);
    next if ($file eq "Pods");
    next if ($file =~ m/Tests/);

    if (-d "$dir/$file") {
      $directories[++$#directories] = "$dir/$file";
    } else {
      if ($file =~ m/.m$/) {
        # at the moment we only care about .m files
        print "$dir/$file\n";

        open( my $input_fh, "<", "$dir/$file" ) || die "Can't open $dir/$file: $!";

        my @lines = <$input_fh>;
        my $line_idx = 0;

        foreach(@lines) {
          # now do we have an instance of @"" that isn't precedded by NSLocalizedString?
          $line_idx++;

          my $line = $_;

          if ($line =~ m/@\"/) {
            if ($line !~ m/NSLocalizedString|NSLog|NSAssert|XCTAssert/) {
              print "$dir/$file [$line_idx] $line";
            }
          }
        }
      }
    }
  }

  closedir(DIR);

  if (scalar @directories > 0) {
    foreach(@directories) {
      read_dir($_);
    }
  }
}

my $directory = '.';

read_dir($directory);
