inherit update-alternatives

ALTERNATIVE:${PN} = "cuda"
ALTERNATIVE_LINK_NAME[cuda] = "${prefix}/local/cuda"
ALTERNATIVE_TARGET[cuda] = "${prefix}/local/cuda-${CUDA_VERSION}"
ALTERNATIVE_PRIORITY[cuda] = "114"
