# Exercise 8 - Rolling back to Previous Version
[< PREV](7-zero-downtime-deployment.md) | [TOC](README.md) | [NEXT >](9-cloud-migration.md)


## Goals

* Learn about Kubernetes concepts: deployment rollback

## Acceptance Criteria

* Use the `kubectl` tool to rollback the `pet-web` deployment to previous version
* Cleanup resources in minikube cluster

## Step by Step Instructions

Let's first check the revisions of the `pet-web` deployment:

```shell
$ kubectl rollout history deployment pet-web
deployments "pet-web"
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
$ kubectl rollout history deployment pet-web --revision=1
deployments "pet-web" with revision #1
Pod Template:
  Labels:	app=pet
	pod-template-hash=2789397899
	tier=frontend
  Containers:
   pet-web:
    Image:	pet-app
    Port:	8080/TCP
    Environment:
      SPRING_PROFILES_ACTIVE:	mysql
      PET_DB_DATABASE:	petclinic
      PET_DB_USER:	petclinic-user
      PET_DB_PASSWORD:	<set to the key 'password' in secret 'mysql-pass'>	Optional: false
    Mounts:	<none>
  Volumes:	<none>
$ kubectl rollout history deployment pet-web --revision=2
  deployments "pet-web" with revision #2
  Pod Template:
    Labels:	app=pet
  	pod-template-hash=474843257
  	tier=frontend
    Containers:
     pet-web:
      Image:	pet-app:step-7
      Port:	8080/TCP
      Environment:
        SPRING_PROFILES_ACTIVE:	mysql
        PET_DB_DATABASE:	petclinic
        PET_DB_USER:	petclinic-user
        PET_DB_PASSWORD:	<set to the key 'password' in secret 'mysql-pass'>	Optional: false
      Mounts:	<none>
    Volumes:	<none>
```

You can see revision 2 has the tagged image, while revision 1 has the untagged
image. Let's rollback to the previous untagged version:

```shell
$ kubectl rollout undo deployment pet-web
deployment.apps "pet-web"
```

Refresh the page in your browser to test the application was rolled back and the
welcome message reverted to the previous "Welcome" message.

Once everything is tested, let's cleanup our minikube resources, using the
`kubectl delete` command:

```shell
$ kubectl delete -f kubernetes/web.yml -f kubernetes/mysql.yml
service "pet-web" deleted
deployment "pet-web" deleted
service "pet-db" deleted
persistentvolumeclaim "db-pv-claim" deleted
deployment "pet-db" deleted
$ kubectl get pod
No resources found.
$ kubectl get service
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   7d
$ kubectl get deployment
No resources found.
```

Then we can stop our minikube cluster:

```shell
$ minikube stop
Stopping local Kubernetes cluster...
Machine stopped.
```
