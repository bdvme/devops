sudo ansible-playbook -i inventory/cluster/hosts.yml -b --diff cluster.yml

# kubectl configuration
mkdir -p ~/.kube
sudo cp inventory/cluster/artifacts/admin.conf ~/.kube/config
sudo cp inventory/cluster/artifacts/kubectl /usr/local/bin/kubectl

sudo chown vagrant:vagrant ~/.kube/config