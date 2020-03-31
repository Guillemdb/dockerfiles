ARG FROM_CUDA_VERSION=10.1
ARG CUDA_CONTAINER_VERSION="latest"
FROM fragiletech/cuda-${FROM_CUDA_VERSION}:${CUDA_CONTAINER_VERSION}
ARG CUDA_VERSION=10.1
ARG INSTALL_PYTORCH=true
ARG INSTALL_TENSORFLOW=true
ARG REMOVE_DEV=true
ARG INSTALL_PHANTOM_JS=true
ARG PYTHON_VERSION="3.7"
ARG REMOVE_DEV=false

ENV BROWSER=/browser \
    LC_ALL=en_US.UTF-8

COPY requirements.txt requirements.txt
COPY Makefile Makefile
# Install system packages
RUN apt-get update && \
	apt-get install -y --no-install-suggests --no-install-recommends make cmake && \
    make install-python${PYTHON_VERSION} && \
    make install-common-dependencies && \
    if [ "${INSTALL_PHANTOM_JS}" = true ] ; then make install-phantomjs UBUNTU_NAME="$(lsb_release -s -c)"; fi && \
    make install-python-libs

RUN if [ "${INSTALL_PYTORCH}" = true ] ; then make install-pytorch; fi
RUN if [ "${INSTALL_TENSORFLOW}" = true ]  ; then make install-tf PYTHON_VERSION=${PYTHON_VERSION} CUDA_VERSION=${CUDA_VERSION}; fi
RUN if [ "${REMOVE_DEV}" = true ] ; then make remove-dev-packages; fi

RUN mkdir /root/.jupyter && \
    echo 'c.NotebookApp.token = "'${JUPYTER_PASSWORD}'"' > /root/.jupyter/jupyter_notebook_config.py
CMD jupyter notebook --allow-root --port 8080 --ip 0.0.0.0