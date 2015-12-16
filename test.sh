#!/bin/bash
for filename in test/*.lisp
do
    echo -e " ----------------- Executing $filename -----------------\n"
    sbcl --script "$filename"
    echo -e "\n"
    #echo -e "\n ----------------- End $filename tests -----------------\n"
done

#for filename in tests/*.sh
#do
#    echo -e " ----------------- Executing $filename -----------------\n"
#    ./"$filename"
#    echo -e "\n"
#    #echo -e "\n ----------------- End $filename tests -----------------\n"
#done

