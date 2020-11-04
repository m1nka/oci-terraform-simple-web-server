data "oci_core_images" "sws_image" {
  compartment_id    = var.compartment_ocid
  operating_system  = "Oracle Linux"
  shape             = var.compute_shape
}

locals {
  oracle_linux = lookup(data.oci_core_images.sws_image.images[0],"id")
}

resource "tls_private_key" "public_private_key_pair" {
  algorithm   = "RSA"
}

resource "oci_core_instance" "sws_vm" {
  compartment_id        = var.compartment_ocid
  availability_domain   = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
  shape                 = var.compute_shape

  source_details {
    source_id     = local.oracle_linux
    source_type   = "image"
  }
  create_vnic_details {
    subnet_id         = oci_core_subnet.sws_sn.id
    display_name      = "primary_vnic"
    assign_public_ip  = true
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  timeouts {
    create = "5m"
  }

  display_name          = "Simple Webserver Virtual Machine"
}

resource "null_resource" "remote-exec" {
  depends_on = [oci_core_instance.sws_vm]
  
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.sws_vm.public_ip
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  
    inline = [
      "sudo /bin/yum install -y nginx",
      "sudo /bin/systemctl start nginx",
      "sudo /bin/firewall-offline-cmd --add-port=80/tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index.original.html",
      "sudo chmod 777 /usr/share/nginx/html/index.html",
      "echo '<html><h1>Hello Sweet World.</h1></html>' > /usr/share/nginx/html/index.html",
    ]
  }
}

output "public_ip" {
    value = oci_core_instance.sws_vm.public_ip
}

output "public_key" {
  value = tls_private_key.public_private_key_pair.public_key_openssh
}
output "private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
}