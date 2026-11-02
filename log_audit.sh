#!/usr/bin/env bash

# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o: If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline.
set -euo pipefail

# Print a normal message
log() { 
    # prints all positional arguments as a singe string, followed by a newline
    printf '%s\n' "$*"
}

# Print an error message and exit
die() {
    #In shell scripting, all variables are global by default. 
    #To restrict a variable's scope so it does not bleed into the rest of your script by local.
    local exit_code="$1"
    local message="$2"

    log "ERROR: $message"
    exit "$exit_code"
}

# Check arguments
if [[ "$#" -ne 1 ]]; then # number of arguments is not equal to 1
    die 2 "Usage: $0 Missing argument: path to log directory"
fi

log_dir="$1"

# Validate directory
if [[ ! -d "$log_dir" || ! -r "$log_dir" || ! -x "$log_dir" ]]; then 
    # Directory does not exist or cannot be read or not executed
    die 3 "Directory does not exist or cannot be read: $log_dir"
fi

# Enable nullglob to handle directories without .log files
# shopt -s nullglob enables the Bash nullglob option. By default, 
# if a wildcard pattern such as *.log does not match any files, 
# Bash treats the pattern as a literal string. When nullglob is enabled, 
# Bash instead expands an unmatched pattern to nothing. 
# This means that if a directory contains no .log files, the array files=("$log_dir"/*.log) 
# will be empty rather than containing the text *.log. This 
# helps prevent errors when your script processes files in a directory that has no matching log files.
shopt -s nullglob 

# Find all .log files
files=( "$log_dir"/*.log ) # *.log: every file that ends with .log

# Counters
scanned=0
flagged=0

# Process each log file
for file in "${files[@]}"; do # files[@]: all elements of an array named files

    # Count lines containing ERROR
    # awk '/ERROR/ { count++ }: For each line that matches the pattern ERROR, increment the count variable by 1.
    # END { print count+0 }: After processing all lines, print the final count, 
    # and ensure that if no lines matched, it prints 0 instead of nothing.
    error_count=$(awk '/ERROR/ { count++ } END { print count +0 }' "$file")

    scanned=$((scanned + 1)) # one more file scanned

    filename="${file##*/}" # file##*/: Extract filename from path

    log "$filename: $error_count errors" # print filename and number of errors

    # Flag files with MORE than 10 errors
    if (( error_count > 10 )); then

        review_dir="$log_dir/review"

        # Create review directory if necessary
        mkdir -p "$review_dir" # create directories, without throwing an error if the directory already exists

        # Copy original file into review directory
        # "--" tells cp that subsequent arguments are filenames, not options.
        cp -- "$file" "$review_dir/"  # create a copy of the file in the review directory

        flagged=$((flagged + 1))

        log "FLAGGED: $filename copied to review/"
    fi

done

# Print final summary
log "--------------------------------"
log "Files scanned: $scanned"
log "Files flagged: $flagged"

# Exit status
if (( flagged > 0 )); then
    exit 1
fi

exit 0