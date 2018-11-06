# Exercise 0 - Building and Running Locally
[Next >](1-docker.md)

## Goals

* Build and package the sample application using Maven
* Run the application on your local workstation
* Familiarize yourself with the user interface / features:
  * Create an Owner
  * Add a Pet
  * Browse Veterinarians
  * Find the Owner you created

## Acceptance Criteria

* Application is running on http://localhost:8080
* New Owner is created, with at least 1 pet

## Step by Step Instructions

We will use the Maven wrapper to build the project, running either the `package`
or `install` target from the root of the project:

```shell
$ ./mvnw clean install
Downloading https://repo1.maven.org/maven2/org/apache/maven/apache-maven/3.3.3/apache-maven-3.3.3-bin.zip
................................................................................
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building petclinic 2.0.0.BUILD-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]

(...)

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:23 min
[INFO] Finished at: 2018-04-05T13:32:24+01:00
[INFO] Final Memory: 103M/933M
[INFO] ------------------------------------------------------------------------
```

Once the project is built, you can run the Spring Boot Maven plugin with
`./mvnw spring-boot:run`. Example:

```shell
$ ./mvnw spring-boot:run
[INFO] Scanning for projects...
[INFO]                                                                         
[INFO] ------------------------------------------------------------------------
[INFO] Building petclinic 2.0.0.BUILD-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] >>> spring-boot-maven-plugin:2.0.0.RELEASE:run (default-cli) > test-compile @ spring-petclinic >>>

(...)

2018-04-05 13:34:44.322  INFO 57532 --- [  restartedMain] o.s.j.e.a.AnnotationMBeanExporter        : Located MBean 'dataSource': registering with JMX server as MBean [com.zaxxer.hikari:name=dataSource,type=HikariDataSource]
2018-04-05 13:34:44.427  INFO 57532 --- [  restartedMain] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2018-04-05 13:34:44.431  INFO 57532 --- [  restartedMain] o.s.s.petclinic.PetClinicApplication     : Started PetClinicApplication in 12.261 seconds (JVM running for 13.44)
```

Then you should be able to access the application by going to http://localhost:8080.
