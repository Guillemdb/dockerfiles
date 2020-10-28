NVIDIA_DRIVER_VERSION=440.44
CUDA_VERSION=10.1
CUDA_VERSION_FULL=10.1.243
CUDA_VERSION_DASH=10-1

.PHONY: install-cuda
install-cuda:
	apt-get update && \
	apt-get install -y gnupg && \
	wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_${CUDA_VERSION_FULL}-1_amd64.deb &&\
	dpkg -i cuda-repo-ubuntu1804_10.1.243-1_amd64.deb && \
	rm cuda-repo-ubuntu1804_${CUDA_VERSION_FULL}-1_amd64.deb && \
	apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub && \
	apt-get update && \
	apt-get -y install --no-install-suggests --no-install-recommends \
		libcublas10 \
		cuda-cudart-${CUDA_VERSION_DASH} \
		cuda-cufft-${CUDA_VERSION_DASH} \
		cuda-curand-${CUDA_VERSION_DASH} \
		cuda-cusolver-${CUDA_VERSION_DASH} \
		cuda-cusparse-${CUDA_VERSION_DASH}

.PHONY: install-cuda-10.1
install-cuda-10.1:
	make install-cuda \
	CUDA_VERSION_FULL=10.1.243 \
	CUDA_VERSION=10.1 \
	CUDA_VERSION_DASH=10-1 &&\
	sed -i 's#"$#:/usr/local/cuda-10.1/bin"#' /etc/environment && \
	apt-get remove -y gnupg kmod&& \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


.PHONY: install-nvidia-driver
install-nvidia-driver:
	apt-get update && \
	apt-get install -y kmod && \
	mkdir -p /opt/nvidia && cd /opt/nvidia/ && \
	wget http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run -O /opt/nvidia/driver.run && \
	chmod +x /opt/nvidia/driver.run && \
	/opt/nvidia/driver.run -a -s --no-nvidia-modprobe --no-kernel-module --no-unified-memory --no-x-check --no-opengl-files && \
	rm -rf /opt/nvidia

.PHONY: install-tf
install-tf:
	@if [ "${PYTHON_VERSION}" = "3.6" ];\
	then \
		pip3 install tensorflow-gpu; \
	else \
	  	if [ "${CUDA_VERSION}" = "10.2" ];\
	  	then \
			pip3 install https://github.com/inoryy/tensorflow-optimized-wheels/releases/download/v2.1.0/tensorflow-2.1.0-cp37-cp37m-linux_x86_64.whl; \
		else \
			pip3 install https://github.com/inoryy/tensorflow-optimized-wheels/releases/download/v2.0.0/tensorflow-2.0.0-cp37-cp37m-linux_x86_64.whl; \
		fi \
	fi

.PHONY: install-pytorch
install-pytorch:
	pip3 install torch torchvision