#!/bin/bash

_KEY_FILE="$DIR_CA/enc.key"

x-crypt() {
  local operation=$1
  local args="--batch --pinentry-mode loopback --passphrase-file ${_KEY_FILE}"
  local in_file=$2
  local out_file=$3

  case "$1" in
    encrypt)
      gpg ${args} --output "${out_file}" --symmetric --cipher-algo AES256 "${in_file}"
      ;;
    decrypt)
      gpg ${args} --output "${out_file}" --decrypt "${in_file}"
      ;;
  esac
}

encrypt() {
  local in_file=$1
  local rel_path=$(echo "${in_file}" | sed "s#${DIR_CA_WORKING_DIR}/##g")
  local meta_file="${DIR_CA_MNT}/${rel_path}.enc.meta"
  local out_file="${DIR_CA_MNT}/${rel_path}.enc"

  local file_hash=$(sha1sum "${in_file}" | cut -d " " -f 1)
  local meta_tmp=$(mktemp)
  echo "${file_hash}" > "${meta_tmp}"

  mkdir -p $(dirname "${out_file}")

  x-crypt encrypt "${meta_tmp}" "${meta_file}"
  x-crypt encrypt "${in_file}" "${out_file}"
  echo "Done encrypting ${in_file}"
  rm "${meta_tmp}"
}

decrypt() {
  local enc_file=$1
  local rel_path=$(echo "${enc_file}" | sed "s#${DIR_CA_MNT}/##g")
  local dir_name=$(dirname "${rel_path}")
  local out_name=$(basename "${enc_file}" ".enc")
  local meta_file="${enc_file}.meta"
  local out_file="${DIR_CA_WORKING_DIR}/${dir_name}/${out_name}"
  local meta_tmp=$(mktemp)
  local out_tmp=$(mktemp)

  x-crypt decrypt "${meta_file}" "${meta_tmp}"
  x-crypt decrypt "${enc_file}" "${out_tmp}"

  local file_hash=$(sha1sum "${out_tmp}" | cut -d " " -f 1)
  local meta_hash=$(cat "${meta_tmp}")

  if [ "${file_hash}" != "${meta_hash}" ]; then
    echo "FILE HASHES DO NOT MATCH"
    echo "${file_hash} != ${meta_hash}"
    exit 1
  fi
  mv "${out_tmp}" "${out_file}"
  rm "${meta_tmp}" "${out_tmp}"
}