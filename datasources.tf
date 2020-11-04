// Provides a list of Availability Domains, see https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}