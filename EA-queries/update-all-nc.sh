#!/bin/bash
for f in *.sql ; do
    grep -v '^--' $f > $f-nc
done
