# Exercise 15 - Cleanup
[< Prev](14-canary-release.md)


## Goals

* Ensure all cloud resources are disposed

## Acceptance Criteria

* Use terraform to teardown the GKE infrastructure

## Step by Step Instructions

Since all our infrastructure was deployed to GKE, we can use the `terraform
destroy` command to cleanup everything and ensure we're not paying for unused
cloud resources:

```shell
$ terraform destroy terraform/
google_container_cluster.cluster: Refreshing state... (ID: devops-workshop-gke)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - google_container_cluster.cluster


Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

google_container_cluster.cluster: Destroying... (ID: devops-workshop-gke)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 10s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 20s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 30s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 40s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 50s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 1m0s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 1m10s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 1m20s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 1m30s elapsed)
google_container_cluster.cluster: Still destroying... (ID: devops-workshop-gke, 1m40s elapsed)
google_container_cluster.cluster: Destruction complete after 1m42s

Destroy complete! Resources: 1 destroyed.
```

Then, we can run the following script to cleanup all the unused Google Cloud
resources, replacing your Project ID in two occurrences:

```shell
$ GCLOUD_PROJECT_ID=devops-workshop-123 ./gcloud-cleanup.sh
+ set +e
+ PROJECT_ID=devops-workshop-123
+ deleteContainerImages pet-app
+ APP=pet-app

...
```

These steps will destroy all resources we created during the workshop, but if
you want to also shut down your entire GCP "Devops Workshop" project, you can do
so through the Management Console by going to the "IAM & admin" service,
choosing the "Settings" menu and clicking on "SHUT DOWN" button.
