# Use this script to create your own image and push it to ic-registry.

docker login ic-registry.epfl.ch
docker build ubuntu-base -t ubuntu20-base --no-cache
docker tag ubuntu20-base ic-registry.epfl.ch/ivrl/ubuntu20-base
docker push ic-registry.epfl.ch/ivrl/ubuntu20-base