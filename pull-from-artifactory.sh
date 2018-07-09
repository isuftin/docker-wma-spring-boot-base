repo_url="https://cida.usgs.gov/artifactory/$1"
group=$2
artifact=$3
version=$4
output=$5
if [ "$version" = "LATEST" ] || [ "$version" = "latest" ]; then
    version=`curl -k -s $repo_url/$(echo "$group" | tr . /)/$artifact/maven-metadata.xml | grep latest | sed "s/.*<latest>\([^<]*\)<\/latest>.*/\1/"`
fi
echo "fetch "$repo_url/$(echo "$group" | tr . /)/$artifact/$version/$artifact-$version.jar""
curl -k -o $output -X GET "$repo_url/$(echo "$group" | tr . /)/$artifact/$version/$artifact-$version.jar"
echo -e "Artifact: $group.$artifact\nVersion: $version\nRetireved At: $(date)" >> artifact-metadata.txt