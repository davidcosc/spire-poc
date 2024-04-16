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
#FILE="./go1.22.2.linux-amd64.tar.gz"
echo "Installing golang ......"
snap install go --classic
echo "Installing golang ..[ok]"
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
echo "Starting containers ......"
cd spire
docker compose up -d
cd ..
echo "Starting containers ..[ok]"
EXP=$(printf "Selector         : docker:label:com.docker.compose.service:client\nSelector         : docker:label:com.docker.compose.service:server\n")
ACT=$(docker exec server-spire "/usr/bin/spire-server" entry show | grep docker:label:com.docker.compose.service)
if test "$EXP" != "$ACT"; then
  echo "Registering workloads ......"
  docker exec server-spire "/usr/bin/spire-server" entry create -parentID "spiffe://example.org/spire/agent/tpm/704b57fb7dff7c5f01d468a1f1dd42b2b83d7bcf1989539db05c77cd178b781c" -spiffeID "spiffe://example.org/server" -selector "docker:label:com.docker.compose.service:server"
  docker exec server-spire "/usr/bin/spire-server" entry create -parentID "spiffe://example.org/spire/agent/tpm/704b57fb7dff7c5f01d468a1f1dd42b2b83d7bcf1989539db05c77cd178b781c" -spiffeID "spiffe://example.org/client" -selector "docker:label:com.docker.compose.service:client"
  echo "Registering workloads ..[ok]"
fi
