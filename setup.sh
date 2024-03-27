#!/bin/bash
set -e
echo "Update and upgrade ......"
apt update && apt upgrade -y
echo "Update and upgrade ..[ok]"
echo "Installing docker ......"
apt install docker.io -y
echo "Installing docker ..[ok]"
echo "Installing docker-compose ......"
apt install docker-compose-v2 -y
echo "Installing docker-compose ..[ok]"
echo "Installing git ......"
apt install git -y
echo "Installing git ..[ok]"
FILE="./spire-tutorials"
echo "Cloning spire tutorials ......"
if test -d "${FILE}"; then
  echo "Spire tutorials already cloned."
  echo "Cloning spire tutorials ..[ok]"
else
  git clone https://github.com/spiffe/spire-tutorials.git
  echo "Cloning spire tutorials ..[ok]"
fi
echo "Replace old docker-compose cmd with docker compose cmd ......"
echo "Sed ./spire-tutorials/docker-compose/metrics/test.sh"
sed -i 's/docker-compose /docker compose /' ./spire-tutorials/docker-compose/metrics/test.sh
echo "Sed ./spire-tutorials/docker-compose/metrics/scripts/clean-env.sh"
sed -i 's/docker-compose /docker compose /' ./spire-tutorials/docker-compose/metrics/scripts/clean-env.sh
echo "Sed ./spire-tutorials/docker-compose/metrics/scripts/create-workload-registration-entry.sh"
sed -i 's/docker-compose /docker compose /' ./spire-tutorials/docker-compose/metrics/scripts/create-workload-registration-entry.sh
echo "Sed ./spire-tutorials/docker-compose/metrics/scripts/fetch_svid.sh"
sed -i 's/docker-compose /docker compose /' ./spire-tutorials/docker-compose/metrics/scripts/fetch_svid.sh
echo "Sed ./spire-tutorials/docker-compose/metrics/scripts/set-env.sh"
sed -i 's/docker-compose /docker compose /' ./spire-tutorials/docker-compose/metrics/scripts/set-env.sh
echo "Replace old docker-compose cmd with docker compose cmd ..[ok]"
echo "Testing setup ......"
./spire-tutorials/docker-compose/metrics/test.sh
echo "Testing setup ..[ok]"
