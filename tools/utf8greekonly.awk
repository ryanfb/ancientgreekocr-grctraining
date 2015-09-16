#!/usr/bin/awk -f
#
# Outputs valid UTF-8 Greek words into a file called "grcwords".
# Any words which don't appear to be valid or UTF-8 Greek are
# discarded.
#
# Note that the set of characters matching Greek includes the
# combining diacritical marks (U+0300 - U+036F).

/^[Ͱ-Ͽἀ-῝-ͯ]*$/ { print; }
