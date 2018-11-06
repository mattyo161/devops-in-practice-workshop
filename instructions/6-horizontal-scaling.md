# Exercise 6 - Scaling up our Application
[< PREV](5-application-kubernetes.md) | [TOC](README.md) | [NEXT >](7-zero-downtime-deployment.md)


## Goals

* Learn about Kubernetes concepts: replica sets and deployments
* Scaling a deployment

## Acceptance Criteria

* Demonstrate using `kubectl` to scale the number of pods for the web application
from 1 to 3

## Step by Step Instructions

Run the following `kubectl` command to increase the `pet-web` deployment to 3
replicas:

```shell
$ kubectl scale deployment pet-web --replicas=3
deployment "pet-web" scaled
```

Verify that it worked:

```shell
$ kubectl get deployment
NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
pet-db    1         1         1            1           17h
pet-web   3         3         3            3           3h
$ kubectl get pod
NAME                      READY     STATUS    RESTARTS   AGE
pet-db-7997cf844-lsppt    1/1       Running   0          17h
pet-web-bc5d4c9f6-2j26j   1/1       Running   0          3h
pet-web-bc5d4c9f6-l4klv   1/1       Running   0          28s
pet-web-bc5d4c9f6-nxf78   1/1       Running   0          28s
```

Get the external service URL to test the application continues to work:

```shell
$ minikube service pet-web --url
http://192.168.99.100:30596
```

Visiting the URL in your browser (in this case http://192.168.99.100:30596)
should open the PetClinic application.
