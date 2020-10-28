#!/bin/bash

CONTAINER_NAME="deep-learning"
PYTHON_VERSION="3.7"
UBUNTU_VERSION="19.04"
INSTALL_PHANTOM_JS=false
INSTALL_TENSORFLOW=false
INSTALL_PYTORCH=false
CONTAINER_VERSION="latest"
NO_DEEP_LEARNING=false
NVIDIA_DRIVER_VERSION=440.44
CUDA_VERSION=10.1
CUDA_VERSION_FULL=10.1.243
CUDA_VERSION_DASH=10-1
ONLY_CUDA=false
# Parse args

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  case "$1" in
    -py | --python ) PYTHON_VERSION="$2"; shift 2;;
    -cu | --cuda ) CUDA_VERSION="$2"; shift 2;;
    -nd | --nvidia-driver ) NVIDIA_DRIVER_VERSION="$2"; shift 2;;
    -tf | --tensorflow ) INSTALL_TENSORFLOW=true; shift;;
    -pt | --pytorch ) INSTALL_PYTORCH=true; shift;;
    -b | --no-dl ) NO_DEEP_LEARNING=true; shift;;
    -j | -js | --phantomjs ) INSTALL_PHANTOM_JS=true; shift;;
    -cn | --container-name) CONTAINER_NAME="$2"; shift 2;;
    -v | --version) CONTAINER_VERSION="$2"; shift 2;;
    -oc | --only-cuda) ONLY_CUDA=true; shift;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done

if [ "${PYTHON_VERSION}" = "3.6" ]; then  UBUNTU_VERSION="18.04"
fi

if [ "${NO_DEEP_LEARNING}" = "true" ] && [ ${CONTAINER_NAME} = "deep-learning" ]; then \
  CONTAINER_NAME=base-py;
fi

if [ "${CUDA_VERSION}" = "10.2" ]; then \
  CUDA_VERSION_FULL="10.2.89"; CUDA_VERSION_DASH="10-2"; \
fi

if [ "${NO_DEEP_LEARNING}" = "true" ]; then \
  echo "Building python container with no deep learning:";
  echo "Container name:" ${CONTAINER_NAME};
  echo "Container version": ${CONTAINER_VERSION};
  echo "Ubuntu version:" ${UBUNTU_VERSION};
  echo "Python version:" "${PYTHON_VERSION}";
  echo "Install Phantom js:" ${INSTALL_PHANTOM_JS};
else
  echo "Building deep learning container:";
  echo "Container name:" ${CONTAINER_NAME};
  echo "Container version": ${CONTAINER_VERSION};
  echo "Ubuntu version:" ${UBUNTU_VERSION};
  echo "Python version:" "${PYTHON_VERSION}";
  echo "Nvidia driver version" ${NVIDIA_DRIVER_VERSION};
  echo "CUDA version:" ${CUDA_VERSION_FULL};
  echo "Install tensorflow:" ${INSTALL_TENSORFLOW};
  echo "Install pytorch:" ${INSTALL_PYTORCH};
  echo "Phantom js:" ${INSTALL_PHANTOM_JS};
fi

if [ "${NO_DEEP_LEARNING}" = "true" ]; then \
  docker build --pull -t fragiletech/${CONTAINER_NAME}${PYTHON_VERSION}:${CONTAINER_VERSION} \
    -f base-python.dockerfile . \
    --build-arg INSTALL_PHANTOM_JS=${INSTALL_PHANTOM_JS} \
    --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
    --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
    --build-arg INSTALL_PYTORCH=${INSTALL_PYTORCH} \
    --build-arg INSTALL_TENSORFLOW=${INSTALL_TENSORFLOW};
else \
  docker build --pull -t fragiletech/cuda-${CUDA_VERSION}:${CONTAINER_VERSION} \
    -f base-nvidia-cuda.dockerfile . \
    --build-arg CUDA_VERSION=${CUDA_VERSION} \
    --build-arg CUDA_VERSION_DASH=${CUDA_VERSION_DASH} \
    --build-arg CUDA_VERSION_FULL=${CUDA_VERSION_FULL} \
    --build-arg NVIDIA_DRIVER_VERSION=${NVIDIA_DRIVER_VERSION} \
    --build-arg UBUNTU_VERSION=${UBUNTU_VERSION};
  if [ "${ONLY_CUDA}" = "false" ]; then \
    docker build -t fragiletech/${CONTAINER_NAME}-py${PYTHON_VERSION}-cuda${CUDA_VERSION}:${CONTAINER_VERSION} \
      -f data-science.dockerfile . \
      --build-arg INSTALL_PYTORCH=${INSTALL_PYTORCH} \
      --build-arg INSTALL_TENSORFLOW=${INSTALL_TENSORFLOW} \
      --build-arg CUDA_VERSION=${CUDA_VERSION} \
      --build-arg FROM_CUDA_VERSION=${CUDA_VERSION} \
      --build-arg CUDA_CONTAINER_VERSION=${CONTAINER_VERSION} \
      --build-arg INSTALL_PHANTOM_JS=${INSTALL_PHANTOM_JS};
  fi
fi
