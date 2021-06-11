resource "aws_default_security_group" "default_sg" {
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
  
}

data "aws_ami" "latest_amazon_linux_image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = [var.image_name]
    }
}


resource "aws_key_pair" "ssh_key" {
    key_name = "server-ssh-key"
    #public_key = var.my_public_key
    public_key = file(var.public_key_location)

}

resource "aws_instance" "myapp_server" {
    ami = data.aws_ami.latest_amazon_linux_image.id
    instance_type = var.instance_type

    vpc_security_group_ids = [aws_default_security_group.default_sg.id]
    subnet_id = var.subnet_id
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    #key_name = "jenkins-ssh"
    key_name = aws_key_pair.ssh_key.key_name

    user_data = file("./entry-script.sh")
    tags = {
      "Name" = "${var.env_prefix}-server"
    }
}

