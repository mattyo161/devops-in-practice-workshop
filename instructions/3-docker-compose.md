# Exercise 3 - Bundling containers with Docker Compose
[< Prev](2-persistent-volume.md)  [Next >](4-mysql-kubernetes.md)

## Goals

* Define and run multi-container Docker application with Docker Compose

## Acceptance Criteria

* Running `docker-compose up` should rebuild and launch MySQL and application containers

## Step by Step Instructions

Create a file called `docker-compose.yml` at the root of the project with the
following content:

```yaml
version: '2'

services:
  pet-app:
    build:
      context: .
      args:
        JAR_FILE: "./target/spring-petclinic-2.0.0.BUILD-SNAPSHOT.jar"
    image: pet-app
    ports:
      - "8080:8080"
    links:
      - database:pet-db
    environment:
      SPRING_PROFILES_ACTIVE: "mysql"
  database:
    image: mysql:5.7
    expose:
      - 3306
    volumes:
      - ./data:/var/lib/mysql
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
      MYSQL_DATABASE: "petclinic"
      MYSQL_USER: "petclinic-user"
      MYSQL_PASSWORD: "S3cr3t"
```

Then you can use `docker-compose build` to rebuild the application container:

```shell
$ docker-compose build
database uses an image, skipping
Building pet-app
Step 1/4 : FROM openjdk:8-jdk-alpine
 ---> 224765a6bdbe
Step 2/4 : ARG JAR_FILE
 ---> Using cache
 ---> d21d87bb325b
Step 3/4 : ADD ${JAR_FILE} app.jar
 ---> 05b4e0502c2e
Step 4/4 : ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
 ---> Running in 116e70b2b89e
Removing intermediate container 116e70b2b89e
 ---> 66d4ecdaae23
Successfully built 66d4ecdaae23
Successfully tagged devopsinpracticeworkshop_pet-app:latest
```

Once the container image is built and tagged, you can start all the containers
with a single `docker-compose up` command:

```shell
$ docker-compose up
Starting devopsinpracticeworkshop_database_1 ... done
Recreating devopsinpracticeworkshop_pet-app_1 ... done
Attaching to devopsinpracticeworkshop_database_1, devopsinpracticeworkshop_pet-app_1
database_1  | 2018-04-05T21:18:53.544497Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
database_1  | 2018-04-05T21:18:53.560127Z 0 [Note] mysqld (mysqld 5.7.21) starting as process 1 ...

...
```

Then you should be able to access the application by going to http://localhost:8080

Once you tested that everything is working, you can stop the containers by
pressing `Ctrl+C` and cleaning up using the `docker-compose down` command:

```shell
$ docker-compose down
Removing devops-in-practice-workshop_pet-app_1  ... done
Removing devops-in-practice-workshop_database_1 ... done
Removing network devops-in-practice-workshop_default
```
