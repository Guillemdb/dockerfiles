#!/bin/bash

CONTAINER_TYPE="base"
PYTHON_VERSION="3.7"
UBUNTU_VERSION="18.04"
INSTALL_CUDA=false
INSTALL_PHANTOM_JS=false
CONTAINER_VERSION="latest"

# Parse args
POSITIONAL=()
while [[ $# -gt 0 ]]
do
  case "$1" in
    -py | --python ) PYTHON_VERSION="$2"; shift 2;;
    -cu | --cuda ) INSTALL_CUDA=true; shift;;
    -ba | --base ) INSTALL_CUDA=false; shift;;
    -j | -js | --phantomjs ) INSTALL_PHANTOM_JS=true; shift;;
    -cn | --container-name) CONTAINER_NAME="$2"; shift 2;;
    -v | --version) CONTAINER_VERSION="$2"; shift 2;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done

if [ "${PYTHON_VERSION}" = "3.8" ] || [ "${PYTHON_VERSION}" = "3.9" ]; then  UBUNTU_VERSION="20.04"
fi


if [ "${INSTALL_CUDA}" = "true" ]; then \
  CONTAINER_TYPE="cuda";
fi


echo "Building docker container:";
echo "Container type:" ${CONTAINER_TYPE};
echo "Container version": "${CONTAINER_VERSION}";
echo "Ubuntu version:" ${UBUNTU_VERSION};
echo "Python version:" "${PYTHON_VERSION}";
echo "Install Phantom js:" ${INSTALL_PHANTOM_JS};


if [ "${INSTALL_CUDA}" = "true" ]; then \
  export CONTAINER_NAME=fragiletech/ubuntu"${UBUNTU_VERSION}"-cuda-11.0-py"${PYTHON_VERSION//.}":${CONTAINER_VERSION}
else
  export CONTAINER_NAME=fragiletech/ubuntu"${UBUNTU_VERSION}"-base-py"${PYTHON_VERSION//.}":${CONTAINER_VERSION}
fi
echo "CONTAINER NAME" ${CONTAINER_NAME};
if [ "${INSTALL_CUDA}" = "true" ]; then \
  docker build --pull -t "${CONTAINER_NAME}" \
    -f base-cuda.dockerfile . \
    --build-arg INSTALL_PHANTOM_JS=${INSTALL_PHANTOM_JS} \
    --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
    --build-arg UBUNTU_VERSION=${UBUNTU_VERSION};
else \
  docker build --pull -t "${CONTAINER_NAME}" \
    -f base-python.dockerfile . \
    --build-arg INSTALL_PHANTOM_JS=${INSTALL_PHANTOM_JS} \
    --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
    --build-arg UBUNTU_VERSION=${UBUNTU_VERSION};
fi
