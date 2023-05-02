#!/bin/bash

CORRAL_api_host="${CORRAL_fqdn}"
echo "corral_set api_host=${CORRAL_api_host}"

config="write-kubeconfig-mode: 644
cni: ${CORRAL_cni}
tls-san:
  - ${CORRAL_api_host}
"

if [ "${CORRAL_registry_fqdn}" ]; then
  config+="system-default-registry: ${CORRAL_registry_fqdn}"
fi

CORRAL_rke2_install_command="curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${CORRAL_kubernetes_version}"
echo "corral_set rke2_install_command=${CORRAL_rke2_install_command}"
CORRAL_sh_args="-"
echo "corral_set sh_args=${CORRAL_sh_args}"

mkdir -p /etc/rancher/rke2
cat > /etc/rancher/rke2/config.yaml <<- EOF
${config}
EOF

FULL_COMMAND="$CORRAL_rke2_install_command sh $CORRAL_sh_args"

eval ${FULL_COMMAND}
systemctl enable rke2-server.service
systemctl start rke2-server.service

sed -i "s/127.0.0.1/${CORRAL_api_host}/g" /etc/rancher/rke2/rke2.yaml

echo "corral_set kubeconfig=$(cat /etc/rancher/rke2/rke2.yaml | base64 -w 0)"
echo "corral_set node_token=$(cat /var/lib/rancher/rke2/server/node-token)"
