FROM nvcr.io/nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
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
 && rm -rf /var/lib/apt/lists/*


# Install Python 3.8 with Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && /opt/conda/bin/conda install mkl numpy scipy pandas ipython jupyter \
    && /opt/conda/bin/conda clean --all -y

ENV PATH="/opt/conda/bin:/usr/local/cuda/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/cuda/lib64"

# Make $PATH and $LD_LIBRARY PATH available to all users
RUN echo PATH="${PATH}" >> /etc/environment && \
    echo LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" >> /etc/environment

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


# PyTorch
RUN pip3 --no-cache-dir install \
    torch==1.10.0+cu113 \
    torchvision==0.11.1+cu113 \
    torchaudio==0.10.0+cu113 \
    -f https://download.pytorch.org/whl/cu113/torch_stable.html


RUN pip --no-cache-dir install \
    jupyter \
    jupyterlab \
    visdom \
    nbconvert \
    tensorboardX \
    tornado \
    ipywidgets \
    seaborn \
    opencv-contrib-python-headless

RUN jupyter nbextension enable --py widgetsnbextension


USER root
RUN mkdir /opt/lab
COPY setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/

