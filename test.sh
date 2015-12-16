#!/bin/bash
error=0
for filename in test/*.lisp
do
    echo -e " ----------------- Executing $filename -----------------\n"

    output=`sbcl --script "$filename" | grep "TOTAL" | awk '{print $5}'`
     echo "[$output]"
    if [[ $output -gt 0 ]]; then
        #echo $output
        error=`expr $error + $output`
    fi
    echo -e "\n"
    #echo -e "\n ----------------- End $filename tests -----------------\n"
done
if [[ $error -gt 0 ]]; then
    echo "$error errors"
    exit 1
fi
