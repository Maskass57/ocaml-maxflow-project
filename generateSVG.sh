#!/bin/sh

rm *.svg
PATH=$(ls *.dot)
for i in $PATH 
do 
	dot -Tsvg $i > $i.svg  
	xdg-open $i.svg
done
