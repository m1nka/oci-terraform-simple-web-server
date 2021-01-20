// Required variables for Terraform provider to work

variable "tenancy_ocid" {}
variable "region" {
  default = "eu-frankfurt-1"
}

// Additional variables for the simple web server

variable "compartment_ocid" {}
variable "AD" {
  default = "1"
}

// Set variable to "VM.Standard.E2.1.Micro" to provision a free tier instance VM.Standard2.1
variable "compute_shape" {
  default = "VM.Standard.E2.1.Micro"
}