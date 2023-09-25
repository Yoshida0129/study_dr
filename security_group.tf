resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  description = "test_sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    self              = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.pri_ip]
  security_group_id = aws_security_group.test_sg.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type             = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  cidr_blocks      = [var.pri_ip]
  security_group_id = aws_security_group.test_sg.id
}
