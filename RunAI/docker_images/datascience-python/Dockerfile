FROM ubuntu:20.04
MAINTAINER Ehsan Pajouheshgar<ehsan.pajouheshgar@epfl.ch>


RUN apt-get update &&  DEBIAN_FRONTEND="noninteractive" TZ="Europe/Zurich" apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    cmake wget vim htop \
    python3 python3-dev python3-pip python-is-python3 \
    hdf5-tools h5utils \
    zip \
    unzip \
    ssh \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install \
	numpy scipy scikit-image scikit-learn \
	matplotlib seaborn \
	pillow imageio h5py \
	pandas \
	opencv-contrib-python-headless \
    jupyter \
    jupyterlab \
    tqdm \
    ipywidgets



RUN jupyter nbextension enable --py widgetsnbextension


USER root
RUN mkdir /opt/lab
COPY setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/

