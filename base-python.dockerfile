ARG UBUNTU_VERSION=19.04
FROM ubuntu:${UBUNTU_VERSION}

ARG INSTALL_PHANTOM_JS=true
ARG PYTHON_VERSION="3.7"
ARG REMOVE_DEV=true
ARG INSTALL_TENSORFLOW=false
ARG INSTALL_PYTORCH=false

ENV BROWSER=/browser \
    LC_ALL=en_US.UTF-8
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/cuda-${CUDA_VERSION}/bin:bin/sh
#ENV UBUNTU_NAME="$(lsb_release -s -c)"
COPY requirements.txt requirements.txt
COPY Makefile Makefile
#RUN apt-get update && apt-get install -y lsb-release && UBUNTU_NAME="$(lsb_release -s -c)" && echo "UBUNTU NAME" ${UBUNTU_NAME}
# Install system packages
RUN apt-get update && \
	apt-get install -y --no-install-suggests --no-install-recommends make cmake && \
    make install-python${PYTHON_VERSION} && \
    make install-common-dependencies
RUN if [ "${INSTALL_PHANTOM_JS}" = true ] ; then make install-phantomjs UBUNTU_NAME="$(lsb_release -s -c)"; fi
RUN make install-python-libs PYTHON_VERSION=${PYTHON_VERSION}
RUN if [ "${INSTALL_PYTORCH}" = true ] ; then make install-pytorch; fi
RUN if [ "${INSTALL_TENSORFLOW}" = true ] ; then \
    make install-tf PYTHON_VERSION=${PYTHON_VERSION} CUDA_VERSION=${CUDA_VERSION}; \
    fi
RUN if [ "${REMOVE_DEV}" = true ] ; then make remove-dev-packages; fi

