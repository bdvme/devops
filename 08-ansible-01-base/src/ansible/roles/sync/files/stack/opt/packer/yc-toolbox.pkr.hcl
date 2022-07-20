# YC Toolbox VM Image based on Ubuntu 20.04 LTS
#
# Yandex Packer provisioner docs:
# https://www.packer.io/docs/builders/yandex
#

variable "folder_id" {
  type = string
  default = "folder_id"
}

variable "token" {
  type = string
  default = "token"
  sensitive = true
}

variable "YC_ZONE" {
  type = string
  default = "ru-central1-a"
}

variable "subnet_id" {
  type = string
  default = "subnet_id"
}

variable "TF_VER" {
  type = string
  default = "1.1.9"
}

variable "KCTL_VER" {
  type = string
  default = "1.23.0"
}

variable "HELM_VER" {
  type = string
  default = "3.9.0"
}

variable "GRPCURL_VER" {
  type = string
  default = "1.8.6"
}

variable "GOLANG_VER" {
  type = string
  default = "1.17.2"
}

variable "PULUMI_VER" {
  type = string
  default = "3.36.0"
}

source "yandex" "yc-toolbox" {
  folder_id           = "${var.folder_id}"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "ubuntu"
  use_ipv4_nat        = "true"
  image_description   = "Yandex Cloud Ubuntu Toolbox image"
  image_family        = "my-images"
  image_name          = "yc-toolbox"
  subnet_id           = "${var.subnet_id}"
  disk_type           = "network-hdd"
  token               = "${var.token}"
  zone                = "${var.YC_ZONE}"
}

build {
  sources = ["source.yandex.yc-toolbox"]

  provisioner "shell" {
    inline = [
      # Global Ubuntu things
      "sudo apt-get update",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get install -y unzip python3-pip python3.8-venv",

      # Yandex Cloud CLI tool (YC)
      "curl -s -O https://storage.yandexcloud.net/yandexcloud-yc/install.sh",
      "chmod u+x install.sh",
      "sudo ./install.sh -a -i /usr/local/ 2>/dev/null",
      "rm -rf install.sh",
      "sudo sed -i '$ a source /usr/local/completion.bash.inc' /etc/profile",

      # Docker
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce containerd.io",
      "sudo usermod -aG docker $USER",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo useradd -m -s /bin/bash -G docker yc-user",

      # Docker Artifacts
      "docker pull hello-world",
      "docker pull -q amazon/aws-cli",
      "docker pull -q golang:${var.GOLANG_VER}",

      # Terraform (classic way)
      #"curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-keyring.gpg",
      #"echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null",
      #"sudo apt-get update",
      #"sudo apt-get install -y terraform",
      #
      # Alternative Option
      "curl -sL https://hashicorp-releases.yandexcloud.net/terraform/${var.TF_VER}/terraform_${var.TF_VER}_linux_amd64.zip -o terraform.zip",
      "unzip terraform.zip",
      "sudo install -o root -g root -m 0755 terraform /usr/local/bin/terraform",
      "rm -rf terraform terraform.zip",
      # Terraform configuration file ?
      #"cat <<EOF > ~/.terraformrc \n provider_installation { network_mirror { url = \"https://terraform-mirror.yandexcloud.net/\" include = [\"registry.terraform.io/*/*\"] } direct { exclude = [\"registry.terraform.io/*/*\"] } } \n EOF",

      # kubectl
      "curl -s -LO https://dl.k8s.io/release/v${var.KCTL_VER}/bin/linux/amd64/kubectl",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
      "rm -rf kubectl",

      # Helm
      "curl -sSLO https://get.helm.sh/helm-v${var.HELM_VER}-linux-amd64.tar.gz",
      "tar zxf helm-v${var.HELM_VER}-linux-amd64.tar.gz",
      "sudo install -o root -g root -m 0755 linux-amd64/helm /usr/local/bin/helm",
      "rm -rf helm-v${var.HELM_VER}-linux-amd64.tar.gz",
      "rm -rf linux-amd64",
      # User can add own repo after login like this:
      # helm repo add stable https://charts.helm.sh/stable

      ## grpccurl
      "curl -sSLO https://github.com/fullstorydev/grpcurl/releases/download/v${var.GRPCURL_VER}/grpcurl_${var.GRPCURL_VER}_linux_x86_64.tar.gz",
      "tar zxf grpcurl_${var.GRPCURL_VER}_linux_x86_64.tar.gz",
      "sudo install -o root -g root -m 0755 grpcurl /usr/local/bin/grpcurl",
      "rm -rf grpcurl_${var.GRPCURL_VER}_linux_x86_64.tar.gz",
      "rm -rf grpcurl",

      # Pulumi
      "curl -sSLO https://get.pulumi.com/releases/sdk/pulumi-v${var.PULUMI_VER}-linux-x64.tar.gz",
      "tar zxf pulumi-v${var.PULUMI_VER}-linux-x64.tar.gz",
      "sudo cp pulumi/* /usr/local/bin/",
      "rm -rf pulumi-v${var.PULUMI_VER}-linux-x64.tar.gz",
      "rm -rf pulumi",

      # Other packages
      "sudo apt-get install -y git jq tree tmux",

      # Clean
      "rm -rf .sudo_as_admin_successful",

      # Test - Check versions for installed components
      "echo '=== Tests Start ==='",
      "yc version",
      "terraform version",
      "docker version",
      "kubectl version --client=true",
      "helm version",
      "grpcurl --version",
      "git --version",
      "jq --version",
      "tree --version",
      "pulumi version",
      "echo '=== Tests End ==='"
    ]
  }
}
