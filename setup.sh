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
echo "Installing tpm2 tools ......"
apt install tpm2-tools tss2 -y
echo "Installing tpm2 tools ..[ok]"
FILE="./get_tpm_pubhash"
echo "Building spire with tpm plugin ......"
if test -f "${FILE}"; then
  echo "Spire tpm plugin already exists."
  echo "Building spire with tpm plugin ..[ok]"
else
  echo "Building spire image."
  cd spire
  docker build -t spire-tpm-plugin .
  docker run -dit --name spire-tpm-plugin spire-tpm-plugin "/usr/bin/spire-server" "run"
  sleep 3
  cd ..
  echo "Copying binaries from container."
  docker cp "spire-tpm-plugin:/go/spire-tpm-plugin/build/linux/amd64/get_tpm_pubhash" .
  docker cp "spire-tpm-plugin:/go/spire-tpm-plugin/build/linux/amd64/tpm_attestor_server" .
  docker cp "spire-tpm-plugin:/go/spire-tpm-plugin/build/linux/amd64/tpm_attestor_agent" .
  echo "Cleaning up build container."
  docker stop spire-tpm-plugin
  docker container prune -f
  echo "Generating binary checksums."
  sha256sum ./tpm_attestor_agent > tpm_attestor_agent_hash
  sha256sum ./tpm_attestor_server > tpm_attestor_server_hash
  sed -i "s/  .\/tpm.*//g" tpm_attestor_agent_hash
  sed -i "s/  .\/tpm.*//g" tpm_attestor_server_hash
  echo "Writing checksums to spire agent and server configs."
  MYVAR="$(cat tpm_attestor_agent_hash)"; sed -i "s/plugin_checksum = \".*\"/plugin_checksum = \"$MYVAR\"/" spire/agent/agent.conf
  MYVAR="$(cat tpm_attestor_server_hash)"; sed -i "s/plugin_checksum = \".*\"/plugin_checksum = \"$MYVAR\"/" spire/server/server.conf
  echo "Creating tpm ek fingerprint dir for server."
  mkdir -p hashes
  MYVAR="$(./get_tpm_pubhash)"; touch "hashes/${MYVAR}"
  echo "Building spire tpm plugin ..[ok]"
fi
