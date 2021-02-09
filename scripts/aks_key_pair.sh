#!/bin/bash

VAULT_NAME=hub-and-spoke-vault
KEY_PREFIX=aks
TMP_DIR=./temp

function generate {
  echo "generate..."
  ssh-keygen -b 4096 \
    -t rsa \
    -f ${TMP_DIR}/${KEY_PREFIX}-${envCurrent}.rsa \
    -N '' \
    <<<y 2>&1 >/dev/null
}
function send {
  echo "send..."
  az keyvault secret set --vault-name $VAULT_NAME \
    -n "aks-${envCurrent}-ssh-priv" \
    -f "${TMP_DIR}/${KEY_PREFIX}-${envCurrent}.rsa"
  az keyvault secret set --vault-name $VAULT_NAME \
    -n "aks-${envCurrent}-ssh-pub" \
    -f "${TMP_DIR}/${KEY_PREFIX}-${envCurrent}.rsa.pub"
}
function clean {
  echo "clean..."
  rm -f ${TMP_DIR}/*.rsa*
}

function process {
  generate
  send
  clean
}

# Main
envList=( dev staging prod )
envCurrent=""
if [ ! -z "$1" ]; then
  for item in "${envList[@]}"; do
    if [ $1 == $item ]; then
      echo "Current environment is $1"
      envCurrent=$1
      process
      exit
    fi
  done
  if [ "$envCurrent" == "" ]; then
    echo "Environment name incorrect !"
    echo "Use a value in the list: ${envList[@]}"
  fi
else
  echo "You must pass an environment name."
  echo "Use a value in the list: ${envList[@]}"
fi
