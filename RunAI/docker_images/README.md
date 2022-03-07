# Building your own images

The PhD students are responsible for building images for their projects and sharing the images with the students. If
you're a student, ask your supervisor to provide the docker image.

## Setup

To build your own images, install docker on your computer:

```
sudo apt install docker.io
```

and login to our docker image repository:

```
docker login ic-registry.epfl.ch
```

## Dockerfiles

An image is specified by a directory containing a file named *Dockerfile*. Here is
the [Dockerfile documentation](https://docs.docker.com/engine/reference/builder/).

At the beginning, we say on top of which file we build:

```
FROM base_image_tag
```

Other common operations are:

* run commands with `RUN`:

```dockerfile
RUN apt-get update &&  DEBIAN_FRONTEND="noninteractive" TZ="Europe/Zurich" apt-get install -y \
    curl \
    git \
    sudo 
```

* set environment variables with `ENV`:

```
ENV MY_VARIABLE 3
```

* copy files from the current directory

```
COPY local_file /opt/lab/
```

## Existing images

You can view the existing images available in our repository at <https://ic-registry.epfl.ch/>. Please ask your
supervisor to give you access to IVRL namespace. There are also many publicly available images at
the [Docker Hub](https://hub.docker.com/search?q=&type=image) that you can build on top of to create your own image.

We prepared some images which will hopefully be of use to you (click to see Dockerfiles):

### ubuntu-base:

[`ic-registry.epfl.ch/ivrl/ubuntu-base`](ubuntu-base/Dockerfile)

Basic lightweight ubuntu-20 image. Use this image for testing purpose to make sure you got everything right. Since this
is a very light image (~ 100mb), you can create a pod very fast using this image.

### datascience-python:

[`ic-registry.epfl.ch/ivrl/datascience-python`](datascience-python/Dockerfile)

This image (~920mb) includes everything you need for a datascience project using python such as

* Jupyter, and Jupyterlab
* Numpy, Pandas
* Scikit-learn, Scipy
* Matplotlib
* OpenCV

### pytorch1.10:cuda11.

[`ic-registry.epfl.ch/ivrl/pytorch1.10:cuda11.3`](pytorch1.10+cuda11.3)

This image (~6.4gb) contains pytorch and is compatible with both V100 and A100 GPUs in the cluster. Other packages
included are

* Pytorch 1.10 with CUDA 11.3 
* Jupyter, and Jupyterlab
* Numpy, Pandas
* Scikit-learn, Scipy
* Matplotlib
* OpenCV

This image is built upon `nvcr.io/nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04` container from Nvidia.


[comment]: <> (#### lab-pytorch-cuda-ext)

[comment]: <> ([`ic-registry.epfl.ch/cvlab/lis/lab-pytorch-cuda-ext`]&#40;./lab-pytorch-cuda-ext/Dockerfile&#41;)

[comment]: <> (* usual Python numeric libs)

[comment]: <> (* Jupyter)

[comment]: <> (* PyTorch and accessories)

[comment]: <> (* OpenCV)

## Extending an image

In case you want to extend the image, please see this example [ubuntu-base Dockerfile](./ubuntu-base/Dockerfile). Here
we install libraries from the repositories, but it is possible to do much more.

```Dockerfile
# start from the base image
FROM ubuntu:20.04
# FROM nvcr.io/nvidia/pytorch:20.12-py3

RUN apt-get update &&  DEBIAN_FRONTEND="noninteractive" TZ="Europe/Zurich" apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    zip \
    unzip \
    ssh \
 && rm -rf /var/lib/apt/lists/*
```

**Make sure to switch user to ROOT and copy the `setup.sh` script to /opt/lab/ directory inside your Dockerfile**
You can make additional setup by extending the `setup.sh` script . This script sets the user information and gives you
sudo access inside the image. The script should be inside the same directory as your Dockerfile.

```Dockerfile
USER root
RUN mkdir /opt/lab
COPY setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/
```

Once your docker file is ready, build the image
with [`docker build`](https://docs.docker.com/engine/reference/commandline/build/). Assuming it is
in `ubuntu-base/Dockerfile`, the command is:

```
docker build ubuntu-base -t ic-registry.epfl.ch/ivrl/your_username/your_image_tag
```

You can test the image locally, for example with:

```
docker run -it ic-registry.epfl.ch/ivrl/your_username/your_image_tag /bin/bash
```

Once the image is built, we push it to the repository:

```
docker push ic-registry.epfl.ch/ivrl/your_username/your_image_tag
```

Now you can use the image in your pods!

The `build.sh` file provides all these commands at once.

[comment]: <> (### Multi-stage builds)

[comment]: <> (If your software needs to be compiled, you may benefit)

[comment]: <> (from [multi-stage builds]&#40;https://docs.docker.com/develop/develop-images/multistage-build/&#41;:)

[comment]: <> (this involves creating a temporary container with the build tools where the compilation takes place, then we only copy)

[comment]: <> (the results of the compilation to the output image. This saves space in the output image and allows the build process to)

[comment]: <> (be cached.)

