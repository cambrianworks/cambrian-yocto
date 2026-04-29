SUMMARY = "Multi-GPU CUDA stress test"
DESCRIPTION = "A utility to stress test Nvidia GPUs by running them at maximum capacity"
HOMEPAGE = "https://github.com/wilicc/gpu-burn"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=090209293ddf61f16b0e114228ddb6ea"

SRC_URI = "git://github.com/wilicc/gpu-burn.git;branch=master;protocol=https"
SRCREV = "671f4be92477ce01cd9b536bc534a006dbee058f"
PV = "1.0.1"
S = "${WORKDIR}/git"

DEPENDS = "cuda-toolkit"
RDEPENDS:${PN} += " cuda-cudart"

inherit cuda

# Default location for the compare.ptx file
GPU_BURN_LIBDIR = "${libdir}/gpu-burn"

# Reflects the Compute Capability value of 8.7 for Orin SOMs
# https://developer.nvidia.com/cuda/gpus
GPU_BURN_COMPUTE = "87"

do_configure[noexec] = "1"

do_compile() {

    # The Makefile names the compiler binaries
    # directly, rather than using environment variables
    # which results in the wrong set of tools being used.
    # Correct this so that the preferred cross-compiler
    # for the target is used.
    sed -i 's/g++/$(CXX)/g' ${S}/Makefile
    sed -i 's/gcc/$(CC)/g' ${S}/Makefile

    export HOST_CC_BIN="$(echo ${CC} | cut -d' ' -f1)"

    oe_runmake \
        CXX="${CXX}" \
        CC="${CC}" \
        CUDAPATH=${CUDA_PATH} \
        CFLAGS="${CFLAGS} -I${STAGING_DIR_TARGET}${CUDA_INSTALL_PATH}/include -DCOMPARE_PTX_PATH='\"${GPU_BURN_LIBDIR}/compare.ptx\"'" \
        LDFLAGS="${LDFLAGS} -L${STAGING_DIR_TARGET}${CUDA_INSTALL_PATH}/lib64 -L${STAGING_DIR_TARGET}${CUDA_INSTALL_PATH}/lib" \
        COMPUTE=${GPU_BURN_COMPUTE} \
        NVCC=nvcc \
        IS_JETSON=1 \
        NVCCFLAGS="-allow-unsupported-compiler -ccbin ${HOST_CC_BIN} -Xcompiler --sysroot=${STAGING_DIR_TARGET} -I${STAGING_DIR_TARGET}${includedir}"
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 gpu_burn ${D}${bindir}/gpu-burn

    install -d ${D}${GPU_BURN_LIBDIR}
    install -m 0644 compare.ptx ${D}${GPU_BURN_LIBDIR}
}

FILES:${PN} += "${bindir}/gpu-burn"
FILES:${PN} += "${GPU_BURN_LIBDIR}/compare.ptx"
