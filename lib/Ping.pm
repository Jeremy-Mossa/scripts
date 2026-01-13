package Renamer;

use 5.42.0;
use autodie;
use Exporter 'import';  # this is how perl exports a sub
our @EXPORT_OK = qw(ping);  # export on request


# Exit if no internet access
sub ping() {
  if (system("/bin/ping -c 2 8.8.8.8 > /dev/null 2>&1") != 0)
  {
    print "not online.\n";
    exit;
  }
}
1;  # perl requires for modules to return true
