provider "aws" {
  region     =  "${var.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  profile    = "harmony-foundational"
}


#https://www.reddit.com/r/Terraform/comments/a3qr3i/using_data_statementfilter_to_pull_amazon_linux_2/

data "aws_ami" "fn-node" {
    most_recent = true
    owners = ["amazon"]
    filter {
	    name   = "owner-alias"
	    values = ["amazon"]
    }

    filter {
	    name   = "name"
	    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
    }

    filter {
	    name = "state"
	    values = ["available"]
    }
}

resource "aws_key_pair" "auth" {
  key_name   = "harmony-node"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "foundation-node" {
  ami           =  "${data.aws_ami.fn-node.id}"
  instance_type = "${var.node_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.foundational-sg.id}"]
  key_name = "harmony-node"
  
  provisioner "file" {
    source = "setup.sh"
    destination = "/home/ec2-user/setup.sh"
    connection {
      host = self.public_ip
      type = "ssh"
      user = "ec2-user"
      private_key = "${file(var.private_key_path)}"
      agent = true
    }
  }
  provisioner "file" {
    source = "key-folder/"
    destination = "/home/ec2-user"
    connection {
      host = self.public_ip
      type = "ssh"
      user = "ec2-user"
      private_key = "${file(var.private_key_path)}"
      agent = true
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/setup.sh",
      "/home/ec2-user/setup.sh",
    ]
    connection {
      host = self.public_ip
      type = "ssh"
      user = "ec2-user"
      private_key = "${file(var.private_key_path)}"
      agent = true
    }
  }

  root_block_device  {
    volume_type = "gp2"
    volume_size = "${var.node_volume_size}"
  }

  tags = {
    Name    = "HarmonyFoundationalNode-test"
    Project = "Harmony"
  }

  volume_tags = {
    Name    = "HarmonyFoundationalVolume"
    Project = "Harmony"
  }
}

