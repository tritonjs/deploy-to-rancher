#!/usr/bin/env bash
pushd "/tmp" >/dev/null

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
curl -s -L -u "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" $PROJECT_CONFIG_URL -o config.zip
unzip config.zip
rm config.zip

# Do Upgrade
echo ""
echo "-> Updating service $RANCHER_SERVICE_NAME on $RANCHER_STACK_NAME"
/tmp/rdeploy/rancher-compose -p $RANCHER_STACK_NAME up \
    --force-upgrade --confirm-upgrade --pull \
-d $RANCHER_SERVICE_NAME
