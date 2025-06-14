#!/bin/bash
version=0.1

CAT=$(command -v cat)

FIND=$(command -v find)
LS=$(command -v ls)
SORT=$(command -v sort)

UNIQ=$(command -v uniq)


##Sorting binary files recursively on Linux is not a straightforward task since the binary nature of the files makes it difficult to define a meaningful sorting criterion. However, if you want to sort binary files based on their filenames recursively
##

#### FIND
#### Check to make sure the grep utility is available
if [ ! -f "${FIND}" ]; then
    echo "ERROR: Unable to locate the find binary."
    echo "FIX: Please modify the \${FIND} variables in the program header."
    exit 1
fi

#### LS
#### Check to make sure the grep utility is available
if [ ! -f "${LS}" ]; then
    echo "ERROR: Unable to locate the ls binary."
    echo "FIX: Please modify the \${LS} variables in the program header."
    exit 1
fi

#### SORT
#### Check to make sure the sort utility is available
if [ ! -f "${SORT}" ]; then
    echo "ERROR: Unable to locate the sort binary."
    echo "FIX: Please modify the \${SORT} variable in the program header."
    exit 1
fi


find /path/to/directory -type f -exec ls -l --time=none {} + | sort -k 9