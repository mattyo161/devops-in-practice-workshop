# Exercise 4 - Running MySQL on Kubernetes
[< Prev](3-docker-compose.md)  [Next >](5-application-kubernetes.md)

## Goals

* Learn about Kubernetes concepts: Pods, Services, Deployments
* Learn about minikube
* Learn to provision a Persistent Volume in Kubernetes
* Learn to use Kubernetes to manage secrets
* Learn about the `kubectl` CLI tool
* Deploy a single-instance MySQL database in Kubernetes

## Acceptance Criteria

* Kubernetes files should be in a `kubernetes` folder
* Create a secret in kubernetes using `kubectl` to store the database password
securely
* Create a `deploy.sh` script at the root of the project that uses `kubectl` to
deploy MySQL
* MySQL user password is stored and managed as a kubernetes secret and not stored
in plain-text on any configuration file

## Step by Step Instructions

First of all, let's start minikube to launch a local Kubernetes cluster:

```shell
$ minikube start --memory 4096
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Downloading Minikube ISO
 170.78 MB / 170.78 MB [============================================] 100.00% 0s
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.
```

You can check that the cluster started by running the `kubectl cluster-info` command
or opening a web dashboard by running `minikube dashboard`:

```shell
$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
$ minikube dashboard
Opening kubernetes dashboard in default browser...
```

Now let's create a Kubernetes secret to store the MySQL user password (*please
note the capital S*):

```shell
$ kubectl create secret generic mysql-pass --from-literal password=S3cr3t
secret "mysql-pass" created
$ kubectl get secrets
NAME                  TYPE                                  DATA      AGE
default-token-8856j   kubernetes.io/service-account-token   3         2d
mysql-pass            Opaque                                1         32s
```

We can then create the kubernetes definition file under `kubernetes/mysql.yml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: pet-db
  labels:
    app: pet
spec:
  ports:
    - port: 3306
  selector:
    app: pet
    tier: db
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: db-pv-claim
  labels:
    app: pet
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pet-db
  labels:
    app: pet
spec:
  selector:
    matchLabels:
      app: pet
      tier: db
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: pet
        tier: db
    spec:
      containers:
      - image: mysql:5.7
        name: mysql
        env:
        - name: MYSQL_RANDOM_ROOT_PASSWORD
          value: "yes"
        - name: MYSQL_DATABASE
          value: petclinic
        - name: MYSQL_USER
          value: petclinic-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: db-pv-claim
```

Create a file called `deploy.sh` with the following content:

```bash
#!/usr/bin/env bash
set -xe
kubectl apply -f kubernetes/mysql.yml
```

Change the file permission and execute it:

```shell
$ chmod a+x deploy.sh
$ ./deploy.sh
+ kubectl apply -f kubernetes/mysql.yml
service "pet-db" created
persistentvolumeclaim "db-pv-claim" created
deployment.apps "pet-db" created
```

Validate that the pod started and is in "Running" status using the `kubectl get
pods` command:

```shell
$ kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
pet-db-86955bcb8d-r5z9f   1/1       Running   0          39s
```

You can check the container logs by using the Pod name above and the `kubectl
logs` command:

```shell
$ kubectl logs pet-db-86955bcb8d-r5z9f
Initializing database
2018-04-30T10:25:21.695205Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2018-04-30T10:25:22.255572Z 0 [Warning] InnoDB: New log files created, LSN=45790
2018-04-30T10:25:22.333983Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.

...
```

Also check that the service is running using the `kubectl get service` command:

```shell
$ kubectl get service
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    4m
pet-db       ClusterIP   10.97.164.166   <none>        3306/TCP   1m
```
