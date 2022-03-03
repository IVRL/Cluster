# Use this script to create your own image and push it to ic-registry.

# Usage
# Examples:
# `source build_image.sh ubuntu-base ubuntu20-base`
#	- Build the image for Dockerfile in ubuntu-base directory
# - Tags it as ubuntu20-base and pushes the image to ic-registry

dockerfile_path=$1
tag_name=$2

docker login ic-registry.epfl.ch
cp setup.sh $dockerfile_path
docker build $dockerfile_path -t ic-registry.epfl.ch/ivrl/$tag_name --no-cache
docker push ic-registry.epfl.ch/ivrl/$tag_name
