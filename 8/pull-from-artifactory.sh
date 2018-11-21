#!/bin/bash

repo_url="https://cida.usgs.gov/artifactory/$1"
group=$2
artifact=$3
version=$4
output=$5
artifact_type=${6:-"jar"}
uri_formatted_group=`echo $group | tr . /`
if [ "$version" = "LATEST" ] || [ "$version" = "latest" ]; then
    version=`curl -k -s $repo_url/"$(echo "$group" | tr . /)"/$artifact/maven-metadata.xml | grep latest | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/"`
fi

resource_endpoint="${repo_url}/${uri_formatted_group}/${artifact}/${version}/${artifact}-${version}.${artifact_type}"

echo "$(date) | Start fetch $resource_endpoint"
curl -v --no-tcp-nodelay -o $output "${resource_endpoint}"
echo "$(date) | End fetch $resource_endpoint"
echo "Artifact: ${group}.${artifact}\nVersion: ${version}\nRetireved At: $(date)" >> artifact-metadata.txt
echo "$(date) | Start fetch checksum"
curl --no-tcp-nodelay -o $output.md5 "${resource_endpoint}.md5"
echo "$(date) | End fetch checksum"
artifact_md5=$(md5sum $output | awk '{ print $1 }')
remote_md5=$(cat $output.md5)
test $artifact_md5 == $remote_md5
if [ $? -ne 0 ]; then
  echo "A problem has occurred while downloading artifact from ${resource_endpoint}"
  echo "Downloaded artifact MD5: ${artifact_md5}"
  echo "Expected MD5: ${remote_md5}"
  exit 1
else
  echo "Artifact retrieved from ${resource_endpoint} verified to be valid."
fi
