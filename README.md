# WMA Spring Boot Base Docker

[![Build Status](https://travis-ci.org/USGS-CIDA/docker-wma-spring-boot-base.svg?branch=master)](https://travis-ci.org/USGS-CIDA/docker-wma-spring-boot-base)

This Docker Image provides basic functionality common to all WMA Spring Boot Service Docker Images.

## Usage
### Environment Variables
This docker image provides several environment variables to child images:
 - **SECURITY_REQUIRESSL** [default: true]: Whether or not the service should disallow connections over plain HTTP.
 - **SERVER_PORT** [default: 443]: The port that the application should run on within the container.
 - **serverContextPath** [default: /]: The root context that the application should run on within the container. IMPORTANT NOTE: Your context path **MUST** contain a trailing slash for the health check to work properly.
 - **maxHeapSpace** [deafult: 300M]: The maximum amount of heap space to provide a running JAR file specified in the format of a -Xmx argument to Java. The default values was chosen as a value that seemed to work sufficiently well for all tested services, but this should be modified on a service-by-service basis to get the ebst results.
 - **springFrameworkLogLevel** [deafult: info]: The logging level of the application running within the container.
 - **SERVER_SSL_KEYSTORE** [default: /localkeystore.p12]: The fully-qualified file path that the keystore should be created at.
 - **SERVER_SSL_KEYSTOREPASSWORD** [default: changeme]: The password to use for the keystore.
 - **SERVER_SSL_KEYALIAS** [default: tomcat]: The key alias to use for the SSl certicate that should be served by the application.
 - **ribbonMaxAutoRetries** [default: 3]: The number of times that connections to other services via ribboning should retry before failing.
 - **ribbonConnectTimeout** [default: 1000]: The amount of time to wait before timing out a ribbon connection attempt (in MS).
 - **ribbonReadTimeout** [default: 10000]: The amount of time to wait before timing out while waiting on a response from an established ribbon connection (in MS).
 - **hystrixThreadTimeout** [default: 10000000]: The amount of time hystrix should allow threads to run before timing them out (in MS).
 - **SPRING_CLOUD_CONFIG_ENABLED** [default: false]: Wherher or not the application should attempt to connect to a Spring Cloud Config Server.
 - **TOMCAT_CERT_PATH** [default: /tomcat-wildcard-ssl.crt]: The path where the tomcat cert file is expected to be mounted.
 - **TOMCAT_KEY_PATH** [default: /tomcat-wildcard-ssl.key]: The path where the tomcat key file is expected to be mounted.
 - **HEALTHY_RESPONSE_CONTAINS** [default: '{"status":"UP"}']: The string to expect to be present in the application health check response in order to indicate that the service is healthy.
 - **HEALTH_CHECK_ENDPOINT** [default: "health"]: The URL that Docker should hit to reach the application health check.

## Enabling HTTP

This image encourages using HTTPS by default. If you want to use HTTP, set both `TOMCAT_CERT_PATH` and `TOMCAT_KEY_PATH` to the empty string.

### Health Check
This docker image provides a default health check script which is executed by the Dockerfile HEALTHCHECK command. A script is provided rather than a hard-coded command because when a command with ENV injections is put into the Dockerfile the ENVs are injected at build-time, and as a result if those values are overridden at runtime or by a child Dockerfile the command is *NOT* updated. Using a script the command is evaluated at run-time each time the script is called so the ENV injections are properly evaluated. This script is executed using the "HELATH_***" environment variables supplied above. The default health check script works by pinging the url `https://127.0.0.1:${SERVER_PORT}${serverContextPath}${HEALTH_CHECK_ENDPOINT}` and parsing the response, checking for the existence of `HEALTHY_RESPONSE_CONTAINS` within the returned response.

This default health check can be overridden by providing a `HEALTHCHECK` line at the bottom of the child dockerfile.

### Using Mounted Files
As mentioned above, the `TOMCAT_CERT_PATH` and `TOMCAT_KEY_PATH` variables should be the paths to two mounted files. These files can be mounted into your container in several ways, two of which are listed below.

#### Docker Secrets
The `docker-compose-default.yml` file included in this repo illustrates how these files can be mounted into your container using Docker Secrets.

#### Docker Mount Command
When launching your docker container you can specify files and directories to mount into your container. If you mount a directory to your container containing the cert and key files and it is mounted somewhere other than `/` then you must override the values for `TOMCAT_CERT_PATH` and `TOMCAT_KEY_PATH` to point to the location where the files do get mounted.

### Extending the Base Image
This docker image is not intended to be run on its own, rather other images should inherit from this image in order to utilize its functionality. 

### Pulling down your application
The recommended way to manage the version of the executable artifact running within the container is to define the version to be run as a build argument. This allows you to link a specific version of the Dockerfile with a specific version of the executable. The Dockerfiles for this image define an example build argument, `artifact_Version` to be used for this purpose. When building a downstream image you can override the value of this ARG with the proper version for your application and then pull it from Artifatory with the included `pull-from-artifactory.sh` script, or pull it from another source.

#### The Entrypoint Script
This docker image includes an entrypoint script that configures the keystore properly in order for your application to serve SSL certificates. Additionally, this entrypoint allows for your application to be launched via an additional script (detailed in the next section) if you need to run it with specific arguments or additional configuration. This entrypoint script is added to the docker image as `/entrypoint.sh`. 

Dockerfiles which extend this base image should _**not**_ set their own entrypoint in the Dockerfile _**unless**_ your entrypoint calls the base entrypoint script, recreates the base entrypoint behavior, or your application has its own specific configuration for the keystore. 

If you do choose to override the entrypoint but want to call the base entrypoint script from within your entrypoint you must mount your entrypoint somewhere other than `/entrypoint.sh` to be sure that you do not overwrite the base entrypoint script.

#### Executing your Application
The entrypoint script added by this docker image expects your application to be launched in one of two pre-defined ways. If you cannot support one of these two methods for some reason then you should override the entrypoint script with your own.

1. **/launch-app.sh**: If you add a shell script into the docker container at the path `/launch-app.sh` the entrypoint script will execute that script after setting up the keystore. Within this script your can complete any additional configuration that you may need and launch your JAR file or other artifact.

2. **/app.jar**: If you do not provide a `/launch-app.sh` script then the entrypoint will attempt to directly launch an application JAR file that has been placed at `/app.jar` within the docker container. This jar file is executed using the following command:

    ```bash
    java $JAVA_OPTIONS \
      -Djava.security.egd=file:/dev/./urandom \
      -Djava.security.properties="${HOME}/java.security.properties" \
      -Djavax.net.ssl.trustStore="${JAVA_TRUSTSTORE}" \
      -Djavax.net.ssl.trustStorePassword="${JAVA_TRUSTSTORE_PASS}" \
      -jar "${ARTIFACT}" \
      "$@"
    ```

Note that these files will need to be added into your docker container via your child image Dockerfile using something akin to `ADD app.jar /app.jar`, or via another method (such as a CURL in the Dockerfile). Using the base docker image does _not_ automatically add this file into your image for you.

If neither of the above files are provided in your docker image and you do not override the entrypoint script then the following message will appear and the docker container will exit: `No /launch-app.sh or /app.jar found. Exiting.`

#### Overriding Environment Variables
Any of the environment variables listed above can be overridden in the child docker image by providing a new value for the variable. This value can be provided as an **ENV** value in the Dockerfile itself, as a value in a docker-compose ***.env** file, or via any other method that you might go about assigning a value to an environment variable.
