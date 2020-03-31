ARG UBUNTU_VERSION=19.04
FROM ubuntu:${UBUNTU_VERSION}
ARG NVIDIA_DRIVER_VERSION=440.44
ARG CUDA_VERSION=10.1
ARG CUDA_VERSION_FULL=10.1.243
ARG CUDA_VERSION_DASH=10-1
COPY Makefile Makefile

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-suggests --no-install-recommends -y \
        wget ca-certificates locales git make cmake gcc g++ gnupg \
        pkg-config apt-utils software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install nvidia driver
RUN make install-nvidia-driver \
    NVIDIA_DRIVER_VERSION=${NVIDIA_DRIVER_VERSION} \
    CUDA_VERSION_FULL=${CUDA_VERSION_FULL} \
    CUDA_VERSION=${CUDA_VERSION} \
    CUDA_VERSION_DASH=${CUDA_VERSION_DASH}

# Install cuda
RUN make install-cuda \
    CUDA_VERSION_FULL=${CUDA_VERSION_FULL} \
    CUDA_VERSION=${CUDA_VERSION} \
    CUDA_VERSION_DASH=${CUDA_VERSION_DASH} &&\
    sed -i 's#"$#:/usr/local/cuda-${CUDA_VERSION}/bin"#' /etc/environment && \
	apt-get remove -y gnupg kmod&& \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/cuda-${CUDA_VERSION}/bin:bin/sh

# Install cuddn
RUN wget https://github.com/FragileTech/dockerfiles/raw/master/data/lcdnn${CUDA_VERSION}aa && \
    wget https://github.com/FragileTech/dockerfiles/raw/master/data/lcdnn${CUDA_VERSION}ab && \
    cat lcdnn${CUDA_VERSION}* > libcudnn7_7.6.5.32-1+cuda${CUDA_VERSION}_amd64.deb && \
    rm lcdnn${CUDA_VERSION}* && \
    dpkg -i libcudnn7_7.6.5.32-1+cuda${CUDA_VERSION}_amd64.deb && \
    rm libcudnn7_7.6.5.32-1+cuda${CUDA_VERSION}_amd64.deb