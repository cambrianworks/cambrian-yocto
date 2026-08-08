# Cambrian Yocto Changelog

All notable changes to Cambrian Yocto are documented in this file.

The format is based on [Keep a changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
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
