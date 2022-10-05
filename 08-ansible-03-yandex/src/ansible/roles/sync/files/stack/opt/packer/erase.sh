#!/usr/bin/env bash

# Удалить всё после создания Тераформом
terraform(){
    yc compute instances delete --name clickhouse-01
    yc compute instances delete --name vector-01
    yc compute instances delete --name lighthouse-01
    yc vpc subnet delete --name subnet
    yc vpc net delete --name net
}

# Удалить имейдж, созданный Пакером
packer(){
    yc compute images delete --name centos-7-base
}

if [[ "$1" == "" ]]; then
    terraform
elif [[ "$1" == "packer" ]]; then
    packer
elif [[ "$1" == "terraform" ]]; then
    terraform
fi
