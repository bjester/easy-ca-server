#!/bin/bash

source "${DIR_CA}/func.sh"

echo "Start up decryption starting now"

find "${DIR_CA_MNT}" -type f -name "*.enc" -print0 |
while read -d $'\0' file; do
  echo "Decrypting ${file}"
  decrypt "${file}"
done
