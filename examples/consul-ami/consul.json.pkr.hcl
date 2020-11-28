locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "amazon-linux-2-ami" {
  ami_description = "An Amazon Linux 2 AMI that has Consul installed."
  ami_name        = format("consul-amazon-linux-2-%s",  formatdate("YYYYMMDDhhmmss", timestamp()))
  instance_type   = "t2.micro"
  region          = "{{user `aws_region`}}"
  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "*amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

source "amazon-ebs" "ubuntu16-ami" {
  ami_description = "An Ubuntu 16.04 AMI that has Consul installed."
  ami_name        = format("consul-ubuntu-%s", formatdate("YYYYMMDDhhmmss", timestamp()))
  instance_type   = "t2.micro"
  region          = "{{user `aws_region`}}"
  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

source "amazon-ebs" "ubuntu18-ami" {
  ami_description             = "An Ubuntu 18.04 AMI that has Consul installed."
  ami_name                    = format("consul-ubuntu-%s", formatdate("YYYYMMDDhhmmss", timestamp()))
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  region                      = "{{user `aws_region`}}"
  source_ami_filter {
    filters = {
      architecture                       = "x86_64"
      "block-device-mapping.volume-type" = "gp2"
      name                               = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type                   = "ebs"
      virtualization-type                = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}


build {
  sources = ["source.amazon-ebs.amazon-linux-2-ami", "source.amazon-ebs.ubuntu16-ami", "source.amazon-ebs.ubuntu18-ami"]

  provisioner "shell" {
    inline = ["mkdir -p /tmp/terraform-aws-consul/modules"]
  }


  provisioner "file" {
    destination = "/tmp/terraform-aws-consul/modules"
    source      = "${path.module}/../../modules/"
  }
  provisioner "shell" {
    inline = ["if test -n \"${var.download_url}\"; then", " /tmp/terraform-aws-consul/modules/install-consul/install-consul --download-url ${var.download_url};", "else", " /tmp/terraform-aws-consul/modules/install-consul/install-consul --version ${var.consul_version};", "fi"]
  }
  provisioner "shell" {
    inline = ["/tmp/terraform-aws-consul/modules/install-dnsmasq/install-dnsmasq"]
    only   = ["ubuntu16-ami", "amazon-linux-2-ami"]
  }
  provisioner "shell" {
    inline = ["/tmp/terraform-aws-consul/modules/setup-systemd-resolved/setup-systemd-resolved"]
    only   = ["ubuntu18-ami"]
  }
}
