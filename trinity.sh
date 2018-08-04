#!/bin/bash

. /util/opt/lmod/lmod/init/profile
export -f module

module load trinity/2.4

Trinity "$@"
# Trinity --seqType fa --max_memory 2G --left reads.left.fa.gz --right reads.right.fa.gz --SS_lib_type RF --KMER_SIZE 31 --output trinity_31_out
