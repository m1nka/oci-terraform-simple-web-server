resource "oci_core_vcn" "sws_vcn" {
  cidr_block      = "10.0.0.0/16"
  compartment_id  = var.compartment_ocid

  display_name    = "Simple Web Server VCN"
}

resource "oci_core_internet_gateway" "sws_igw" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.sws_vcn.id

  display_name    = "Simple Web Server IGW"
}

resource "oci_core_route_table" "sws_rt" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.sws_vcn.id
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.sws_igw.id
  }

  display_name    = "Simple Web Server RT"
}

resource "oci_core_subnet" "sws_sn" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.sws_vcn.id
  cidr_block        = "10.0.1.0/24"
  security_list_ids = [oci_core_security_list.sws_sl.id]
  route_table_id    = oci_core_route_table.sws_rt.id

  display_name    = "Simple Web Server SN"
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")
}

resource "oci_core_security_list" "sws_sl" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.sws_vcn.id

  egress_security_rules { 
    destination = "0.0.0.0/0" 
    protocol = "all" 
  }

  ingress_security_rules { 
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options { 
      max = 22
      min = 22 
    }
  }

  ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options { 
      max = 80
      min = 80 
    }
  }

  display_name   = "Simple Web Server Security List"
}


