ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

ARG INSTALL_PHANTOM_JS=true
ARG PYTHON_VERSION="3.7"

ENV BROWSER=/browser \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

#ENV UBUNTU_NAME="$(lsb_release -s -c)"
COPY requirements.txt requirements.txt
COPY Makefile Makefile
#RUN apt-get update && apt-get install -y lsb-release && UBUNTU_NAME="$(lsb_release -s -c)" && echo "UBUNTU NAME" ${UBUNTU_NAME}
# Install system packages
RUN apt-get update && \
	apt-get install -y --no-install-suggests --no-install-recommends make cmake && \
    make install-python${PYTHON_VERSION} && \
    make install-common-dependencies && \
    make install-python-libs
RUN if [ "${INSTALL_PHANTOM_JS}" = true ] ; then make install-phantomjs UBUNTU_NAME="$(lsb_release -s -c)"; fi
RUN if [ "${REMOVE_DEV}" = true ] ; then make remove-dev-packages; fi

