#!/bin/bash

for i in *; do
  old=$i
  new=$(echo $i | grep <file> | sed 's/ \[/\[/g;s/\[[^]]*\]//g;s/o //g')
  mv "$old" "$new"
done
