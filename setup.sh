#!/bin/bash
#$(return 0 2>/dev/null)
#if test "${?}" -ne "0"; then
#  echo "Script should be sourced, but source check returned non zero."
#  exit 1
#fi
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
echo "Installing swtpm ......"
apt install swtpm swtpm-tools tpm2-tools tss2 -y
echo "Installing swtpm ..[ok]"
FILE="/tmp/mytpm2"
echo "Configuring swtpm ......"
if test -d "${FILE}"; then
  echo "Swtpm already configured."
  echo "Configuring swtpm ..[ok]"
else
  mkdir -p "${FILE}"
  chown tss:root "${FILE}"
  swtpm_setup --tpmstate "${FILE}" --create-ek-cert --create-platform-cert --tpm2
  swtpm socket --tpmstate dir="${FILE}" --tpm2 --ctrl type=tcp,port=2322 --server type=tcp,port=2321 --flags not-need-init --daemon
  export TPM_COMMAND_PORT=2321 TPM_PLATFORM_PORT=2322 TPM_SERVER_NAME=localhost TPM_INTERFACE_TYPE=socsim TPM_SERVER_TYPE=raw
  tssstartup
  tssgetcapability -cap 1 -pr 0x01c00000
  echo "Configuring swtpm ..[ok]"
fi
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
