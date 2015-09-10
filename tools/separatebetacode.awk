#!/usr/bin/awk -f
#
# Outputs valid betacode words into a file called "betawords" and
# valid UTF-8 Greek words into a file called "grcwords". Any words
# which don't appear to be valid betacode or UTF-8 Greek are
# discarded.
#
# Note that the set of characters matching Greek includes the
# combining diacritical marks (U+0300 - U+036F).

/^[A-Za-z*()\/=\\+|&']*$/ { print $0 > "betawords"; }

/^[Ͱ-Ͽἀ-῝-ͯ]*$/ { print $0 ; }
