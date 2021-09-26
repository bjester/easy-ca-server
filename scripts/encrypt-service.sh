#!/bin/bash

source "${DIR_CA}/func.sh"
_LOG="${DIR_CA_MNT}/encrypt.log"

exec > >(tee -i "$_LOG")
exec 2>&1

echo "Encrypt service starting up"

find "${DIR_CA_WORKING_DIR}" -type d -exec inotifywait -e close_write,moved_to -m {} + |
while read -r directory events filename; do
  echo "Encrypting ${directory}${filename}"
  encrypt "${directory}${filename}"
done