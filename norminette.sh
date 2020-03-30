#!/bin/bash
# A simple wrapper around the norminette to get proper error code and handle
# the missing caching bug

# cache bug
rm -rf /tmp/launch-*

# pass args of script to norminette
/42norminette/norminette.rb "$@" > /tmp/norminetteoutput

# print output
cat /tmp/norminetteoutput

# count line if > 1 then there is some norme erros
line=$(cat /tmp/norminetteoutput | wc -l)
if [ $line -eq 1 ]; then
  exit 0
else
  exit 1
fi
