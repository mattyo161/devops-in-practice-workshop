# Exercise 9 - Moving to the Cloud: Infrastructure as Code to provision Kubernetes Cluster on GCP
[< PREV](8-rollback.md) | [TOC](README.md) | [NEXT >](10-deploying-to-the-cloud.md)


## Goals

* Learn about Google Cloud Platform (GCP)
* Learn about Google Kubernetes Engine (GKE)
* Learn about Terraform and Infrastructure as Code
* Learn about the GCloud CLI tool

## Acceptance Criteria

* Add Terraform configuration files to a new `terraform` folder at the root of
the project
* Create a High Availability GKE cluster version `1.10.7-gke.6` across 2 zones in
the `us-central1` region using 1 node per zone with instance type `n1-standard-2`
(2 vCPUs, 7.5Gb memory)
* Enable logging and monitoring to be sent to Stackdriver
* Applying Terraform files should create the 2-node GKE cluster, and it's
visible in the GCP Management Console

## Step by Step Instructions

Assuming you already created the GCP project in the pre-workshop setup and you
have the project ID (e.g. `devops-workshop-123`), let's setup `gcloud` CLI to
authenticate to your GCP account and create a new configuration called
`devops-workshop` using the `gcloud init` command and following the wizard:

```shell
$ gcloud init
Welcome! This command will take you through the configuration of gcloud.

Settings from your current configuration [default] are:
compute:
  region: europe-west1
  zone: europe-west1-b
core:
  disable_usage_reporting: 'True'
  project: devops-workshop-123

Pick configuration to use:
 [1] Re-initialize this configuration [default] with new settings
 [2] Create a new configuration
Please enter your numeric choice:  2

Enter configuration name. Names start with a lower case letter and
contain only lower case letters a-z, digits 0-9, and hyphens '-':  devops-workshop
Your current configuration has been set to: [devops-workshop]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.                                                                                                         
Reachability Check passed.
Network diagnostic (1/1 checks) passed.

You must log in to continue. Would you like to log in (Y/n)?  Y

Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?redirect_uri=

You are logged in as: [dtsato@gmail.com].

Pick cloud project to use:
 [1] devops-workshop-123
 [2] esoteric-crow-217
 [3] Create a new project
Please enter numeric choice or text value (must exactly match list
item):  1

Your current project has been set to: [devops-workshop-123].

...
Your Google Cloud SDK is configured and ready to use!

...
```

Before we create our Terraform configuration, let's store the GCP credentials
on a local file to enable Terraform to authenticate and create our cloud
infrastructure:

```shell
$ gcloud auth application-default login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?redirect_uri=...

Credentials saved to file: [/Users/dsato/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests
Application Default Credentials.

To generate an access token for other uses, run:
  gcloud auth application-default print-access-token
```

We also need to make sure the GKE API is enabled (this might take a while):

```shell
$ gcloud services enable container.googleapis.com
Waiting for async operation operations/tmo-acf.9ccd76db-4ccc-40c8-b3a0-a38922fbc8f2 to complete...

Operation finished successfully. The following command can describe the Operation details:
 gcloud services operations describe operations/tmo-acf.9ccd76db-4ccc-40c8-b3a0-a38922fbc8f2
```

PS: If you get an error that the project does not have billing enabled, follow
the link provided in the error message to attach a billing account to the GCP
project, then try the command again.

Now let's create the `terraform/main.tf` file to describe our infrastructure
using the Goggle Cloud provider (you will need to replace the `devops-workshop-123`
value with your project ID):

```terraform
provider "google" {
  project      = "devops-workshop-123"
  region       = "us-central1"
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
```

Now let's initialize Terraform configuration and fetch the necessary provider:

```shell
$ terraform init terraform/

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "google" (1.9.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.google: version = "~> 1.9"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

We can now apply our Terraform definitions and create our GKE cluster by running
the `terraform apply` command (this can take a few minutes):

```shell
$ terraform apply terraform/

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + google_container_cluster.cluster
      id:                                    <computed>
      additional_zones.#:                    "1"
      additional_zones.114014501:            "us-central1-b"
      addons_config.#:                       <computed>
      cluster_ipv4_cidr:                     <computed>
      enable_kubernetes_alpha:               "false"
      enable_legacy_abac:                    "false"
      endpoint:                              <computed>
      initial_node_count:                    "1"
      instance_group_urls.#:                 <computed>
      logging_service:                       "logging.googleapis.com"
      master_auth.#:                         "1"
      master_auth.0.client_certificate:      <computed>
      master_auth.0.client_key:              <computed>
      master_auth.0.cluster_ca_certificate:  <computed>
      master_auth.0.password:                <sensitive>
      master_auth.0.username:                "admin"
      master_version:                        <computed>
      min_master_version:                    "1.10.7-gke.6"
      monitoring_service:                    "monitoring.googleapis.com"
      name:                                  "devops-workshop-gke"
      network:                               "default"
      network_policy.#:                      <computed>
      node_config.#:                         "1"
      node_config.0.disk_size_gb:            "50"
      node_config.0.guest_accelerator.#:     <computed>
      node_config.0.image_type:              <computed>
      node_config.0.local_ssd_count:         <computed>
      node_config.0.machine_type:            "n1-standard-2"
      node_config.0.oauth_scopes.#:          "4"
      node_config.0.oauth_scopes.1277378754: "https://www.googleapis.com/auth/monitoring"
      node_config.0.oauth_scopes.1328717722: "https://www.googleapis.com/auth/devstorage.read_write"
      node_config.0.oauth_scopes.172152165:  "https://www.googleapis.com/auth/logging.write"
      node_config.0.oauth_scopes.299962681:  "https://www.googleapis.com/auth/compute"
      node_config.0.preemptible:             "false"
      node_config.0.service_account:         <computed>
      node_pool.#:                           <computed>
      node_version:                          "1.10.7-gke.6"
      private_cluster:                       "false"
      project:                               <computed>
      region:                                <computed>
      zone:                                  "us-central1-a"


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_container_cluster.cluster: Creating...
  additional_zones.#:                    "" => "1"
  additional_zones.114014501:            "" => "us-central1-b"
  addons_config.#:                       "" => "<computed>"
  cluster_ipv4_cidr:                     "" => "<computed>"
  enable_kubernetes_alpha:               "" => "false"
  enable_legacy_abac:                    "" => "false"
  endpoint:                              "" => "<computed>"
  initial_node_count:                    "" => "1"
  instance_group_urls.#:                 "" => "<computed>"
  logging_service:                       "" => "logging.googleapis.com"
  master_auth.#:                         "" => "1"
  master_auth.0.client_certificate:      "" => "<computed>"
  master_auth.0.client_key:              "<sensitive>" => "<sensitive>"
  master_auth.0.cluster_ca_certificate:  "" => "<computed>"
  master_auth.0.password:                "<sensitive>" => "<sensitive>"
  master_auth.0.username:                "" => "admin"
  master_version:                        "" => "<computed>"
  min_master_version:                    "" => "1.10.7-gke.6"
  monitoring_service:                    "" => "monitoring.googleapis.com"
  name:                                  "" => "devops-workshop-gke"
  network:                               "" => "default"
  network_policy.#:                      "" => "<computed>"
  node_config.#:                         "" => "1"
  node_config.0.disk_size_gb:            "" => "50"
  node_config.0.guest_accelerator.#:     "" => "<computed>"
  node_config.0.image_type:              "" => "<computed>"
  node_config.0.local_ssd_count:         "" => "<computed>"
  node_config.0.machine_type:            "" => "n1-standard-2"
  node_config.0.oauth_scopes.#:          "" => "4"
  node_config.0.oauth_scopes.1277378754: "" => "https://www.googleapis.com/auth/monitoring"
  node_config.0.oauth_scopes.1328717722: "" => "https://www.googleapis.com/auth/devstorage.read_write"
  node_config.0.oauth_scopes.172152165:  "" => "https://www.googleapis.com/auth/logging.write"
  node_config.0.oauth_scopes.299962681:  "" => "https://www.googleapis.com/auth/compute"
  node_config.0.preemptible:             "" => "false"
  node_config.0.service_account:         "" => "<computed>"
  node_pool.#:                           "" => "<computed>"
  node_version:                          "" => "1.10.7-gke.6"
  private_cluster:                       "" => "false"
  project:                               "" => "<computed>"
  region:                                "" => "<computed>"
  zone:                                  "" => "us-central1-a"
google_container_cluster.cluster: Still creating... (10s elapsed)
google_container_cluster.cluster: Still creating... (20s elapsed)
google_container_cluster.cluster: Still creating... (30s elapsed)
google_container_cluster.cluster: Still creating... (40s elapsed)
google_container_cluster.cluster: Still creating... (50s elapsed)
google_container_cluster.cluster: Still creating... (1m0s elapsed)
google_container_cluster.cluster: Still creating... (1m10s elapsed)
google_container_cluster.cluster: Still creating... (1m20s elapsed)
google_container_cluster.cluster: Still creating... (1m30s elapsed)
google_container_cluster.cluster: Still creating... (1m40s elapsed)
google_container_cluster.cluster: Still creating... (1m50s elapsed)
google_container_cluster.cluster: Still creating... (2m0s elapsed)
google_container_cluster.cluster: Still creating... (2m10s elapsed)
google_container_cluster.cluster: Still creating... (2m20s elapsed)
google_container_cluster.cluster: Still creating... (2m30s elapsed)
google_container_cluster.cluster: Still creating... (2m40s elapsed)
google_container_cluster.cluster: Still creating... (2m50s elapsed)
google_container_cluster.cluster: Creation complete after 2m58s (ID: devops-workshop-gke)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Once the cluster is created, we can use the `gcloud` CLI to configure our local
`kubectl` configuration to connect to the Kubernetes cluster in the cloud. Don't
forget to replace the value of the `--project` argument with your own project ID
(in this case it is `devops-workshop-123`):

```shell
$ gcloud container clusters get-credentials devops-workshop-gke --zone us-central1-a --project devops-workshop-123
Fetching cluster endpoint and auth data.
kubeconfig entry generated for devops-workshop-gke.
```

Then we can quickly test that we can list the running services and pods in our
new GKE cluster:

```shell
$ kubectl get services
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.27.240.1   <none>        443/TCP   4m
$ kubectl get pods --namespace kube-system
NAME                                                            READY     STATUS    RESTARTS   AGE
event-exporter-v0.1.7-7c4f8bb746-c9mkz                          2/2       Running   0          4m
fluentd-gcp-v2.0.10-xkk9f                                       2/2       Running   0          4m
fluentd-gcp-v2.0.10-xlq2t                                       2/2       Running   0          4m
heapster-v1.5.0-6b9c895c7d-p676g                                3/3       Running   0          3m
kube-dns-5c5884448b-8zmrt                                       4/4       Running   0          4m
kube-dns-5c5884448b-wjn4x                                       4/4       Running   0          3m
kube-dns-autoscaler-69c5cbdcdd-lcb5j                            1/1       Running   0          4m
kube-proxy-gke-devops-workshop-gke-default-pool-7ea87b46-dm46   1/1       Running   0          4m
kube-proxy-gke-devops-workshop-gke-default-pool-a1700e78-7w81   1/1       Running   0          3m
kubernetes-dashboard-74f855c8c6-flfvk                           1/1       Running   0          4m
l7-default-backend-57856c5f55-xckzv                             1/1       Running   0          4m
metrics-server-v0.2.1-7f8dd98c8f-bx9df                          2/2       Running   0          3m
```

You can also see GKE cluster on the GCP Management Console, by visiting the https://console.cloud.google.com/kubernetes/list URL in your browser.
