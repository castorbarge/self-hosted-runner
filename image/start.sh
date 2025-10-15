#!/bin/bash

echo "Retrieving reg_token..."
ORG=$ORG
REPO=$REPO
PAT_TOKEN=$PAT_TOKEN
NAME=$NAME

result=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${PAT_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/orgs/${ORG}/actions/runners/registration-token")

REG_TOKEN=$(echo $result | jq '.token' | tr -d '"')
echo "Retrieved reg_token: ${REG_TOKEN}"

echo "Running config"
cd /home/docker/actions-runner || exit
./config.sh --url https://github.com/${REPO} --token ${REG_TOKEN} --name ${NAME}

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
