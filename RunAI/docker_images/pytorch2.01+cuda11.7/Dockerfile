FROM nvcr.io/nvidia/pytorch:23.05-py3
MAINTAINER Ehsan Pajouheshgar<ehsan.pajouheshgar@epfl.ch>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  TZ="Europe/Zurich" apt-get install -y \
    curl vim htop\
    ca-certificates \
    cmake \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    zip \
    unzip ssh \
    tmux \
    ffmpeg \
 && rm -rf /var/lib/apt/lists/*



RUN pip3 install jupyter jupyterlab pandas \
                 matplotlib Pillow h5py \
                 tqdm moviepy scipy pyyaml\
                 opencv-contrib-python-headless

RUN pip3 install -U torch \
    torchvision \
    torchaudio --index-url https://download.pytorch.org/whl/cu117

RUN jupyter nbextension enable --py widgetsnbextension


USER root
RUN mkdir /opt/lab
COPY setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/

