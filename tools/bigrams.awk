#!/usr/bin/env awk -f 
# taken from http://www.cis.uni-muenchen.de/kurse/pmaier/Korpus/DataIntensiveLinguistics/node41.html

{ gsub(/[.,:;!?"(){}]/, "")
  for(i= 1; i <= NF; i++){
    bigram = prev " " $i      # build the bigram
    prev = $i                 # keep track of the previous word
    count[bigram]++           # count the bigram
   }
      }
END {for (w in count) 
       print count[w],w
    }
