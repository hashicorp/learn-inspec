# BASIC TERRAFORM EXAMPLE

data "template_file" "example" {
  template = "${var.example}"
}

data "template_file" "example2" {
  template = "${var.example2}"
}

resource "local_file" "example" {
  content  = "${data.template_file.example.rendered} + ${data.template_file.example2.rendered}"
  filename = "example.txt"
}

resource "local_file" "example2" {
  content  = "${data.template_file.example2.rendered}"
  filename = "example2.txt"
}
