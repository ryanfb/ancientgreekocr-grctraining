#!/bin/sh
# See LICENSE file for copyright and license details.

usage="Usage: $0

Takes a dictionary in stdin, and outputs all lines after the first line
starting with 'et,', inclusive."

test $# -ne 0 && echo "$usage" && exit 1

awk -F ',' '$1 == "et" {exit}; {print $1}'
