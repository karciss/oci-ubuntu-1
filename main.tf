# Recurso para una instancia OCI Compute.
resource "oci_core_instance" "ubuntu_vm" {
  compartment_id      = var.compartment_ocid
  display_name        = "ubuntu-web-estatica"
  availability_domain = var.availability_domain
  shape               = "VM.Standard.E3.Flex"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_ocid
  }

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "vnic-ubuntu-web"
    hostname_label   = "ubuntu-web-vm"
  }
  # Metadatos de la clave SSH y del script de inicialización.
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      set -ex

      # Actualizar paquetes e instalar Nginx.
      apt-get update
      apt-get install -y nginx

      # Asegurar el directorio web.
      mkdir -p /var/www/html

      # Copiar el archivo index.html local al servidor.
      cat << 'HTML' > /var/www/html/index.html
      ${file("${path.module}/index.html")}
      HTML
      # Asignar permisos.
      chown -R www-data:www-data /var/www/html
      chmod -R 775 /var/www/html

      # Abrir el puerto HTTP.
      ufw allow 80/tcp || true
      iptables -I INPUT -p tcp --dport 80 -j ACCEPT || true

      # Asegurar que Nginx esté iniciado y habilitado.
      systemctl enable nginx
      systemctl restart nginx

    EOF
    )
  }
}

output "public_ip" {
  value       = oci_core_instance.ubuntu_vm.public_ip
  description = "IP pública del servidor web"
}


