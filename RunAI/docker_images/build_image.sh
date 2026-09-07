# Use this script to create your own image and push it to ic-registry.

# Usage
# Examples:
# `source build_image.sh ubuntu-base ubuntu20-base`
#	- Build the image for Dockerfile in ubuntu-base directory
# - Tags it as ubuntu20-base and pushes the image to the registry
#
# The image folder's own setup.sh is used if it has one; otherwise the shared
# setup.sh in this directory is copied in.

dockerfile_path=$1
tag_name=$2

# docker login ic-registry.epfl.ch
# cp setup.sh $dockerfile_path
# docker build $dockerfile_path -t ic-registry.epfl.ch/ivrl/$tag_name --no-cache
# docker push ic-registry.epfl.ch/ivrl/$tag_name


# Each image can ship its own setup.sh. Only fall back to the shared one in this
# directory when the image folder doesn't have one, so per-image customisations
# are not overwritten.
if [ -f "$dockerfile_path/setup.sh" ]; then
	echo "Using $dockerfile_path/setup.sh"
else
	echo "No setup.sh in $dockerfile_path, using the shared setup.sh"
	cp setup.sh "$dockerfile_path"
fi

docker login registry.rcp.epfl.ch
docker build $dockerfile_path -t registry.rcp.epfl.ch/ivrl/$tag_name --no-cache
docker push registry.rcp.epfl.ch/ivrl/$tag_name