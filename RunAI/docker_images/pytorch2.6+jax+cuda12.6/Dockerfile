FROM nvcr.io/nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04
MAINTAINER Ehsan Pajouheshgar<ehsan.pajouheshgar@epfl.ch>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  TZ="Europe/Zurich" apt-get install -y \
    curl wget vim htop\
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
    python3 python3-pip python3-dev \
 && ln -sf /usr/bin/python3 /usr/local/bin/python \
 && rm -rf /var/lib/apt/lists/*


# JAX and PyTorch both ship their own CUDA libraries inside their pip wheels.
# The CUDA base image points LD_LIBRARY_PATH at the system CUDA 12.6 install,
# which makes JAX pick up the wrong libraries. Clearing it lets each framework
# load the CUDA libs bundled with its own wheel.
ENV LD_LIBRARY_PATH=""

# JAX first, so it resolves its own nvidia-* CUDA 12 wheel versions.
RUN pip3 install "jax[cuda12]"

RUN pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu126

RUN pip3 install flax optax

# moviepy is pinned by request. Note: moviepy 1.0.3 uses Image.ANTIALIAS, which
# Pillow 10 removed, so clip.resize() needs `pip3 install "Pillow<10"` to work.
# The rest are the same convenience packages as the pytorch2.01+cuda11.7 image.
RUN pip3 install matplotlib moviepy==1.0.3 \
                 jupyterlab ipywidgets \
                 wandb \
                 pandas Pillow h5py \
                 tqdm scipy pyyaml \
                 opencv-contrib-python-headless


# Claude Code and Codex. Both installers drop the CLI in $HOME/.local, so we
# give them a shared HOME under /opt and put that on the PATH for every user
# (the cluster user is only created later, by setup.sh).
ENV AI_CLI_HOME="/opt/ai-clis"
RUN mkdir -p ${AI_CLI_HOME} \
 && export HOME=${AI_CLI_HOME} \
 && curl -fsSL https://claude.ai/install.sh | bash \
 && curl -fsSL https://chatgpt.com/codex/install.sh | sh \
 && chmod -R a+rX ${AI_CLI_HOME}

ENV PATH="${AI_CLI_HOME}/.local/bin:/usr/local/cuda/bin:${PATH}"

USER root
RUN mkdir /opt/lab
COPY setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/
