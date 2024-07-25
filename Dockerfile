FROM ubuntu:22.04
LABEL maintainer="Lee Reid <lee.reid1@uqconnect.edu.au>"

SHELL ["/bin/bash", "-c"]

# Add sudo so we can rely on the same install script which states this explicitly
RUN apt-get update \
    && apt-get install -y sudo wget unzip git
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

COPY . /usr/bin/reid-diffusion-basics/
WORKDIR /usr/bin/reid-diffusion-basics/

# We run the FSL install ourselves as the normal way to do it fails in docker images for ubuntu 22.04 without the miniconda flag
RUN source ./install/install-python.sh && \
    install_python && \
    source ./install/install-fsl.sh && \
    install_fsl --miniconda https://github.com/conda-forge/miniforge/releases/download/22.11.1-4/Mambaforge-22.11.1-4-Linux-x86_64.sh

RUN ./install.sh
CMD [ "/usr/bin/reid-diffusion-basics/main.sh" ]
