/* AWS Terraform
   search for `eks`
   aws_eks_cluster
*/


provider "google" {
  project      = "devops-workshop-123"
  region       = "us-east1"
}

resource "google_container_cluster" "cluster" {
  name = "devops-workshop-gke"
  zone = "us-central1-a"
  additional_zones = ["us-central1-b"]
  initial_node_count = 1

  min_master_version = "1.10.7-gke.6"
  master_auth {
    username = "admin"
    password = "choose-a-long-password"
  }

  node_version = "1.10.7-gke.6"
  node_config {
	  machine_type = "n1-standard-2"
	  disk_size_gb = "50"

    oauth_scopes = [
  	  "https://www.googleapis.com/auth/compute",
  	  "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  logging_service = "logging.googleapis.com"
  monitoring_service = "monitoring.googleapis.com"
}
