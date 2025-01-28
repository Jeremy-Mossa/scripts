#!/bin/bash

read -p "Name of perl file: " f
f=$f.pl
touch $f
chmod 755 $f
cat << EOF > $f
#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;


EOF
