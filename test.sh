#!/bin/bash
error=0
for filename in test/*.lisp
do
    echo -e " ----------------- Executing $filename -----------------"
    #output=`sbcl --script "$filename" | grep "assertions passed" | awk '{print $5}'`
    output=`sbcl --script "$filename" | grep "TOTAL"`
    echo $output
    failed=`echo $output | awk '{print $5}'`
    exec_error=`echo $output | awk '{print $7}'`
    if [[ $failed -gt 0 ]] || [[ $exec_error -gt 0 ]]; then
        error=`expr $error + $failed + $exec_error`
    fi
    echo -e "\n"
    #echo -e "\n ----------------- End $filename tests -----------------\n"
done
if [[ $error -gt 0 ]]; then
    echo "$error errors"
    exit 1
fi
