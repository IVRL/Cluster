FROM nvcr.io/nvidia/pytorch:20.12-py3
MAINTAINER Tong Zhang<tong.zhang@epfl.ch>

USER root
# Install some basic utilities
RUN apt-get update &&  DEBIAN_FRONTEND="noninteractive" TZ="Europe/Zurich" apt-get install -y \
    curl vim htop\
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    zip \
    unzip ssh \
    tmux \
 && rm -rf /var/lib/apt/lists/*
# Install python packages via conda.
ENV CONDA_AUTO_UPDATE_CONDA=false
RUN conda install -y "conda>=4.4.11" && conda clean -ya
#################################################
# ADAPT this for your own project!!!
RUN conda install -y \
        h5py \
        matplotlib \
        numpy \
        pillow \
        pyyaml \
        protobuf \
        scipy \
        scikit-image \
        tqdm \
        && \
    conda clean -ya

#RUN conda install pytorch torchaudio cudatoolkit=11.2 -c pytorch
RUN conda install -c pytorch pytorch
RUN conda install -c pytorch torchvision
RUN conda install -c pytorch magma-cuda112

RUN pip --no-cache-dir install \
    jupyter \
    jupyterlab \
    visdom \
    nbconvert \
    tensorboardX \
    tornado \
    scikit-learn

RUN jupyter nbextension enable --py widgetsnbextension


USER root
RUN mkdir /opt/lab
COPY setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/



