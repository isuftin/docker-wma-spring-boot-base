# Spring Boot Base Docker Image

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
### Added
- zmoore@usgs.gov - Initial creation

### Updated
- isuftin@usgs.gov - Shebang on all shell scripts to use /bin/ash
- isuftin@usgs.gov - Clean up apk update to save space
- isuftin@usgs.gov - User creation (default of user 'spring') during container build
- isuftin@usgs.gov - Switch to spring user as primary user
- isuftin@usgs.gov - Entrypoint script cleaned up and now works with non-root user
- isuftin@usgs.gov - Pulling from artifactory also does validation on pulled resource

### Removed
- isutftin@usgs.gov - Travis check for running container by name. Not useful until
  we have a proper sample app to run

### Fixed
- isutftin@usgs.gov - Shell script linting
