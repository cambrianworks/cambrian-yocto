# Cambrian Yocto Changelog

All notable changes to Cambrian Yocto are documented in this file.

The format is based on [Keep a changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Changed
- **[KAS base configuration]** - Updated gig-base-kas-config.yml to remove commit hash for meta-tega repository. This allows builds off latest which includes a JetPack update to R36.5.
- **[linux-jammy-nvidia-tegra]** - Update kernel patch file for R36.5 which enables Message-Signal-Interrupt (MSI) handling of PCIe interface interrupts. Result is the external 10G Ethernet interfaces can run at full speed.
- **[nvidia-kernel-oot]** - Update device tree patch file for R36.5 which enables Message-Signal-Interrupt (MSI) handling of PCIe interface interrupts. Result is the external 10G Ethernet interfaces can run at full speed.
- **[cambrian-image]** - Remove packages deprecated by R36.5 and add new packages related to tensor and CUDA.
- **[README]** - Update README links to external R36.5 documentation.
