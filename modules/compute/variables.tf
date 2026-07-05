variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ami_id" {
  description = "AMI ID for the launch template (use latest Amazon Linux 2 via data source in root module)"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "user_data" {
  description = "Raw user data script run on instance boot"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
  EOF
}

variable "tags" {
  type    = map(string)
  default = {}
}
