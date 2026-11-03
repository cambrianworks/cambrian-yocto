# Cambrian Yocto Changelog

All notable changes to Cambrian Yocto are documented in this file.

The format is based on [Keep a changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Changed

- **[KAS base configuration]** - Advance from scarthgap branch to wrynose.
- **[nvidia-kernel-oot]** - Updated PCIe MSI handling patch to match updated kernel source.
- **[nvidia-kernel-oot]** - Updated patches to include Upstream-Status (now mandatory).
- **[KAS base configuration]** - Fetch bitbake tooling directly since poky has been deprecated.
- **[README]** - Updated flashing instructions.
- **[linux-noble-nvidia-tegra]** - Updated patches to include Upstream-Status (now mandatory).
- **[Yocto recipes]** - Update ${WORKDIR} to ${UNPACKDIR} in all recipes to match updated Yocto syntax.

### Removed

- **[cuda-nvvm]** - intermediate representation compiler tool. Functionality moved into cuda-toolkit and libnvvm.
- **[libcudla]** - Deep Learning Accelerator library. Functionality moved into cuda-toolkit or cuda-libraries.
- **[libnvvpi3]** - Vision Programming Interface. Bumped to libnvvpi4.
- **[nvidia-docker]**- Deprecated in favour of standard docker packages.
- **[tegra-libraries-dla-compiler]** - DLA (Deep Learning Accelerator) offline compiler. Moved into TensorRT.
- **[tegra-nvphs, tegra-nvphs-base]** - NVIDIA Power Hinting Service. Deprecated.
- **[tegra-nvs-base, tegra-nvs-service]** - NVIDIA embedded sensor HAL daemon. Deprecated.
- **[tensorrt-core]** - Refactored to choice of either tensorrt-lean or tensorrt (full). Including tensorrt as replacement.
- **[cuda-compat]** - Not required since Yocto generates an SDK with the same version of CUDA.

### Added

- **[cw-flash-emmc]** - Flashing script to replace functionality of deprecated doflash.sh script.
- **[argus-samples]** - libargus samples.
- **[libnvvm]** - NVIDIA virtual machine compiler libraries.
- **[jetson-sipl-api]** - NVIDIA’s Sensor Input Processing Library (SIPL) for Jetson Linux platforms.
- **[tegra-container-passthrough]** - Container runtime configurations for Yocto filesystems.
- **[tegra-cmake-overrides]** - CMake compatibility fixes.
- **[tegra-eeprom-tool]** - Jetson EEPROM inspection tool.
- **[tegra-libraries-adaruntime]** - CUDA and Tensor runtime for ADA. Equivalent to nvidia-l4t-adaruntime package.
- **[tegra-libraries-camera]** - Userspace interface for camera processing. Equivalent to nvidia-l4t-camera.
- **[tegra-libraries-gbm-backend]** - NVIDIA Generic Buffer Management (GBM) API.
- **[tegra-libraries-openwfd]** - NVIDIA implementation of Khronos OpenWFD (Open Windowing Foundation Display) standard.
- **[tegra-libraries-vulkan]** - NVIDIA implementation a Vulkan compatible driver.
- **[tegra-libraries-vulkan-sc]** - NVIDIA implementation safety-critical Vulkan API.
- **[tegra-libraries-vulkan-sc-core]** - NVIDIA implementation safety-critical Vulkan API.
- **[tegra-nvsci-headers]** - NVIDIA’s NvSci (NVIDIA Software Communication Interface).
- **[zstd]** - lossless data compression utility.

## 2026.10.29 2.1.8

### Fixed

- nvidia-kernel-oot - Trigger PPS inputs on rising, rather than falling edge.

### Added

- nvidia-kernel-oot - Enable UARTs 2, 4, and 5.
## 2026.09.29 2.1.7

### Fixed

- **[linux-jammy-nvidia-tegra]** - Backport keyring related fix.
- **[machine.conf]** - Remove audit logs from debug serial console.

### Added

- **[linux-jammy-nvidia-tegra]** - Include IGC driver.
- **[build.sh]** - Add support for nvidia DevKit as hardware target.
- **[nvidia-kernel-oot]** - Enable GPIO8 as PPS.
- **[build.sh]** - Remove hardcoded targets in build script in favour of JSON based configuration. Include
signing keys in repository in encrypted form.
- **[tegra-binaries]** - Set the default power profile for GigRouter to ID=3 (50W with emphasis on GPUs).

## [2026.06.12] 2.1.6

### Fixed
- **[nvidia-kernel-oot]** - Set PCIe interface to Gen2 speeds.

## [2026.06.03] 2.1.5

### Fixed
- **[gpu-burn]** - Include pre-compiled compare.ptx file for Orin GPU compatibility.

## [2026.05.27] 2.1.4

### Fixed

- **[nvidia-kernel-oot]** - Update DTS overlay to resolve malformed output on secondary serial port (ttyTHS1).

### Added

- **[wireguard]** - Wireguard VPN utilities.
- **[chrony]** - chrony utility and service.

## [2026.05.04] 2.1.3

### Added
- **[gpu-burn]** - Recipe to download and build gpu-burn utility to include in rootfs.
- **[Power profile]** - Added 60W power profile (only for GigCompute).

### Changed
- **[KAS base configuration]** - Updated gig-base-kas-config.yml to remove commit hash for meta-tega repository. This allows builds off latest which includes a JetPack update to R36.5.
- **[linux-jammy-nvidia-tegra]** - Update kernel patch file for R36.5 which enables Message-Signal-Interrupt (MSI) handling of PCIe interface interrupts. Result is the external 10G Ethernet interfaces can run at full speed.
- **[nvidia-kernel-oot]** - Update device tree patch file for R36.5 which enables Message-Signal-Interrupt (MSI) handling of PCIe interface interrupts. Result is the external 10G Ethernet interfaces can run at full speed.
- **[cambrian-image]** - Remove packages deprecated by R36.5 and add new packages related to tensor and CUDA.
- **[README]** - Update README links to external R36.5 documentation.

### Fixed
- **[cw-interactive-serial]**- cw-interactive-serial wasn't being included in final build image without manual rebuilding. Resolved by fixing incorrect variable naming and having the recipe inherit from systemd package.
