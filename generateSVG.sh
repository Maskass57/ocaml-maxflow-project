#!/bin/sh
# DOT NOT USE ; (il est cassé)
rm *.svg
PATH=$(ls *.dot)
for i in $PATH 
do 
	dot -Tsvg $i > $i.svg
done
