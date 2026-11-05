terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

#configurar el proveedor usando la credencial de uso 
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.finger_print
  private_key_path = var.private_key_path
  region           = var.region
}