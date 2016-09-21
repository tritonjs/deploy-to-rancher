#!/usr/bin/env bash
RANCHER_SERVICE_NAME=$(cat /tmp/servicename)
RANCHER_ACCESS_KEY=$(cat /tmp/rak)
RANCHER_SECRET_KEY=$(cat /tmp/rsk)

# Early pushd /tmp to prevent any issues.
pushd "/tmp" >/dev/null

# Load Config.
source /tmp/rdeploy/config.sh

echo ""
echo "-> Rancher: ${RANCHER_URL}"
echo "-> Stack: ${RANCHER_STACK_NAME}"
echo "-> Service: ${RANCHER_SERVICE_NAME}"

echo ""
echo "-> Downloading rancher-compose"
curl -L \
https://github.com/rancher/rancher-compose/releases/download/v0.9.2/rancher-compose-linux-amd64-v0.9.2.tar.gz \
-o /tmp/rancher-compose.tar.gz
tar zxvf rancher-compose.tar.gz --strip-components 2
rm -rf rancher-compose.tar.gz

mv rancher-compose /tmp/rdeploy/rancher-compose
chmod +x /tmp/rdeploy/rancher-compose

echo ""
echo "-> Downloading Rancher Stack Configurations"
PROJECT_CONFIG_URL=$RANCHER_URL"/environments/"$RANCHER_STACK_ID"/composeconfig"
curl -L -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" $PROJECT_CONFIG_URL -o /tmp/config.zip
unzip /tmp/config.zip -d/tmp/rc
rm config.zip

# Remove stale AS & SK
rm -rf /tmp/rak /tmp/rsk

pushd "/tmp/rc" >/dev/null

# Do Upgrade
echo ""
echo "-> Updating service $RANCHER_SERVICE_NAME on $RANCHER_STACK_NAME"
/tmp/rdeploy/rancher-compose --url "${RANCHER_URL}" --access-key "${RANCHER_ACCESS_KEY}" --secret-key "${RANCHER_SECRET_KEY}" -p "${RANCHER_STACK_NAME}" up --force-upgrade --confirm-upgrade --pull -d "${RANCHER_SERVICE_NAME}"
popd "" >/dev/null

echo ""
echo "-> Cleaning up"
rm -rf /tmp/rc
