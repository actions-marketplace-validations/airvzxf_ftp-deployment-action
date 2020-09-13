#!/bin/bash

# TODO: Add list of excluded delete files in two formats, string separated by space and file.

FTP_SETTINGS='set ftp:ssl-allow '${INPUT_SSL_ALLOW}'; set ftp:use-feat '${INPUT_USE_FEAT}';'
FILE_LIST=remote_ftp_list_$(date "+%s").tmp

if [ -z "${INPUT_REMOTE_DIR}" ]; then
  INPUT_REMOTE_DIR="./"
else
  INPUT_REMOTE_DIR="./${INPUT_REMOTE_DIR}/"
fi

if [ "${INPUT_DELETE}" = "true" ]; then
  echo "Deleting from the Server the files and directories with 'lftp'."
  echo -e " Path: ${INPUT_REMOTE_DIR}\n"

  rm -f "${FILE_LIST}"

  lftp \
    -u "${INPUT_USER}","${INPUT_PASSWORD}" \
    "${INPUT_SERVER}" \
    -e "${FTP_SETTINGS} renlist > ${FILE_LIST}; quit;"

  sed -i 's/^\.$/..\n/g' "${FILE_LIST}"
  sed -i ':begin;N;$!b begin;s/\.\.\n//gm' "${FILE_LIST}"

  DELETE_ITEMS=""
  while read -r LINE; do
    if [ -n "$LINE" ]; then
      DELETE_ITEMS=${DELETE_ITEMS}"${INPUT_REMOTE_DIR}$LINE "
    fi
  done <"${FILE_LIST}"

  rm -f "${FILE_LIST}"

  lftp \
    -u "${INPUT_USER}","${INPUT_PASSWORD}" \
    "${INPUT_SERVER}" \
    -e "${FTP_SETTINGS} glob rm -rf ${DELETE_ITEMS} 2>/dev/null; quit;"
fi

echo "INPUT_SERVER: ${INPUT_SERVER}"
echo "INPUT_USER: ${INPUT_USER}"
echo "INPUT_PASSWORD: ${INPUT_PASSWORD}"
echo "INPUT_SSL_ALLOW: ${INPUT_SSL_ALLOW}"
echo "INPUT_USE_FEAT: ${INPUT_USE_FEAT}"
echo "INPUT_DELETE: ${INPUT_DELETE}"
echo "INPUT_LOCAL_DIR: ${INPUT_LOCAL_DIR}"
echo "INPUT_REMOTE_DIR: ${INPUT_REMOTE_DIR}"
