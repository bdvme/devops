#!/bin/sh -x
cd ../terraform
yc config profile create ${yandex_profile}
yc config set folder-id ${yandex_folder_id}
yc config set cloud-id ${yandex_cloud_id}
yc config set token ${yandex_token}
yc config set compute-default-zone ${yandex_zone}
yc config profile activate ${yandex_profile}
yc iam service-account create --name ${yandex_service_acc}
yandex_service_acc_id=$(yc iam service-account get ${yandex_service_acc} | awk 'NR==1{print $2}')
yc resource-manager folder add-access-binding ${yandex_folder_id} --role editor --subject serviceAccount:${yandex_service_acc_id}

yc iam service-account create --name ${yandex_service_admin_acc}
yandex_service_admin_acc_id=$(yc iam service-account get ${yandex_service_admin_acc} | awk 'NR==1{print $2}')
yc resource-manager folder add-access-binding ${yandex_folder_id} --role admin --subject serviceAccount:${yandex_service_admin_acc_id}

yc iam key create --service-account-name ${yandex_service_admin_acc} --output key_admin.json
yc iam key create --service-account-name ${yandex_service_acc} --output key_editor.json
yc config set service-account-key key_admin.json
yc config set token ${yandex_token}