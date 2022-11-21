terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "1.4.1"
    }
  }
}

resource "multipass_instance" "servers" {
  count = 1

  name           = "nomad-server-${format("%02d", count.index + 1)}"
  image          = "22.04"
  cloudinit_file = "./user-data.yaml"
}

resource "multipass_instance" "clients" {
  count = 3

  name           = "nomad-client-${format("%02d", count.index + 1)}"
  image          = "22.04"
  cloudinit_file = "./user-data.yaml"
}

resource "local_file" "ansible_inventory" {
  content = <<EOT
[servers]
%{for server in multipass_instance.servers~}
${server.name}
%{endfor~}

[clients]
%{for client in multipass_instance.clients~}
${client.name}
%{endfor~}
EOT

  filename = "../ansible/hosts.ini"
}
