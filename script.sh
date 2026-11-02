#!/usr/bin/env bash

folder_path=$1
if [ -n "$1" ]; then # the argument is not empty
# take one atgument(folder path)
# for every log file, count how many lines contain error, print filename : N errors
    for file in $1; do
        if[ -f "file" ]; then
            num_error=cat $file | grep ERROR | wc -l
            echo "$file : $num_error errors"
            if [ $num_error > 10 ];then
            # more than 10 error 
                if [ ! -d "review/" ];then # no review folder, create one 
                    mkdir review
                fi
            cp $file review/$file
            fi
        # copy it into a "review/" folder, create review/ if missing
        fi
    done
# print how many files were scanned, how many were flagged
# exit 0: nothing flagged, 1 : something flagged
elif [ -z "$1" ]; then # the argument is empty
# no argument given
# print a usage message("exit 2")
    echo "Error :No argument given."
    exit 2
elif [[ ! -d "$1" ]]; then # the folder does not exist
# folder doesn't exit("exit 3")
    echo "Error :Directory does not exist."
    exit 3
fi
