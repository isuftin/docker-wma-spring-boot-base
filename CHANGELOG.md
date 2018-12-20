# Spring Boot Base Docker Image

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
### Added
- isuftin@usgs.gov - Moved sample app source code into this project from https://github.com/USGS-CIDA/wma-spring-boot-sample
- isuftin@usgs.gov - Add key-store-type to application.yml
- isuftin@usgs.gov - Include a Java 11 build

### Updated
- isuftin@usgs.gov - Copied shell scripts to root dir
- isuftin@usgs.gov - Compose file now specifies the dockerfile to use but keeps context at root
- isuftin@usgs.gov - Make the certificate creation script more versatile
- isuftin@usgs.gov - Add certificates to gitignore
- isuftin@usgs.gov - Update to SHA256 encryption in cert generation
- isuftin@usgs.gov - Update developer connection in pom
- isuftin@usgs.gov - Update launch-app for readability and simplification of code

### Removed
- isuftin@usgs.gov - Removed the onbuild trigger to remove artifact-metadata.txt

## [0.0.2] - 2018-09-27
### Added
- isuftin@usgs.gov - Added wait-for.sh (and the netcat package) to help with
downstream container start orchestration
- Travis waits for container to start before attempting to test
- Parameterize the base openjdk base image via ARG in Dockerfile
- Maintainer label in Dockerfile
- Provide default java options as an ARG in Dockerfile
- ONBUILD triggers for derivative images
- Certificate creation scripting
- Default certificates for testing/development
- pull-from-artifactory.sh - Added "artifact_type" param
- pull-from-artifactory.sh - Artifact download verification

### Updated
- DOCKER_COMPOSE_VERSION for travis YAML
- Travis docker-compose build and launch step
- Switched from alpine base image to Debian slim
- Docker Compose config using YAML expansion fields to re-use code fragments
- Split Compose configuration into Java 8 and Java 10 image builds
- entrypoint.sh better handling of certificate importing

### Removed
- health-check.sh
- docker-compose.env


## [0.0.1] - 2018-07-12
### Added
- zmoore@usgs.gov - Initial creation
- isuftin@usgs.gov - config.env and secrets.env
- isuftin@usgs.gov - maintainer label

### Updated
- isuftin@usgs.gov - Shebang on all shell scripts to use /bin/ash
- isuftin@usgs.gov - Clean up apk update to save space
- isuftin@usgs.gov - User creation (default of user 'spring') during container build
- isuftin@usgs.gov - Switch to spring user as primary user
- isuftin@usgs.gov - Entrypoint script cleaned up and now works with non-root user
- isuftin@usgs.gov - Pulling from artifactory also does validation on pulled resource
- isuftin@usgs.gov - Dockerfile ENV vars now relative to user's home dir
- isuftin@usgs.gov - config.env now specific to spring's user's home
- isuftin@usgs.gov - docker-compose now mounting ssl files in spring's home dir
- isuftin@usgs.gov - entrypoint launching from spring's home dir
- isuftin@usgs.gov - artifact pulling script allows calling script to dictate artifact type

### Removed
- isutftin@usgs.gov - Removed health check script, added inline to Dockerfile
- isutftin@usgs.gov - Travis check for running container by name. Not useful until
  we have a proper sample app to run

### Fixed
- isutftin@usgs.gov - Shell script linting
- isuftin@usgs.gov - entrypoint script properly copying and appending keystore
