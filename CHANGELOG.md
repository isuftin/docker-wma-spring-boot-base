# Spring Boot Base Docker Image

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
### Added
- isuftin@usgs.gov - Added wait-for.sh (and the netcat package) to help with
downstream container start orchestration

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
