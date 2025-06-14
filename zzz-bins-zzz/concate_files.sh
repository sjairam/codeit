#!/bin/bash
version=0.1

CAT=$(command -v cat)
SORT=$(command -v sort)
UNIQ=$(command -v uniq)

#### CAT
#### Check to make sure the cat utility is available
if [ ! -x "${CAT}" ]; then
    echo "ERROR: Unable to locate the cat binary."
    echo "FIX: Please make sure the cat utility is installed and available in PATH."
    exit 1
fi

#### SORT
#### Check to make sure the sort utility is available
if [ ! -x "${SORT}" ]; then
    echo "ERROR: Unable to locate the sort binary."
    echo "FIX: Please make sure the sort utility is installed and available in PATH."
    exit 1
fi

#### UNIQ
#### Check to make sure the uniq utility is available
if [ ! -x "${UNIQ}" ]; then
    echo "ERROR: Unable to locate the uniq binary."
    echo "FIX: Please make sure the uniq utility is installed and available in PATH."
    exit 1
fi

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 file1 file2"
    exit 1
fi

# Capture the file arguments
file1="$1"
file2="$2"

# Check if file1 and file2 exist
if [ ! -f "${file1}" ]; then
    echo "ERROR: File '$file1' does not exist."
    exit 1
fi

if [ ! -f "${file2}" ]; then
    echo "ERROR: File '$file2' does not exist."
    exit 1
fi

# Concatenate, sort, and remove duplicate lines from the files
cat "${file1}" "${file2}" | sort | uniq