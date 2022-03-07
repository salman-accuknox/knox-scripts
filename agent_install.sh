#!/bin/bash
if [[ -z $(kubectl get ns | grep accuknox-agents) ]]
then
  	kubectl create ns accuknox-agents
fi
helm repo add accuknox-agents https://accuknox-agents:OHlrJiRSQV9fencuVmpIawo@agents.accuknox.com/repository/accuknox-agents
helm repo update

#function to install kubearmor cli
install_karmor()
{
        echo "karmor cli tool not found. Installing now:"
        curl -sfL https://raw.githubusercontent.com/kubearmor/kubearmor-client/main/install.sh | sudo sh -s -- -b /usr/local/bin
}

#function to install cilium cli
install_cilium() {
        echo "cilium cli tool not found. Installing now:"
        curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
        sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
        sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
        rm cilium-linux-amd64.tar.gz{,.sha256sum}
}

command -v cilium >/dev/null 2>&1 ||
{
    install_cilium
}
cilium install
cilium hubble enable

command -v karmor >/dev/null 2>&1 ||
{
    install_karmor
}
karmor install

helm install shared-informer-agent-chart accuknox-agents/shared-informer-agent-chart -n accuknox-agents
helm install knox-containersec-chart accuknox-agents/knox-containersec-chart -n accuknox-agents
helm install feeder-service accuknox-agents/feeder-service -n accuknox-agents

echo -ne "Please enter tenant_id and cluster_id: "
read tid cid
kubectl set env deploy/feeder-service -n accuknox-agents tenant_id=$tid cluster_id=$cid
