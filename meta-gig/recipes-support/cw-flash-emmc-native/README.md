# cw-flash-emmc

## Description

In older Yocto branches (e.g., scarthgap) meta-tegra would provide the `doflash.sh` script for writing the image to eMMC while in recovery mode. Since wrynose `doflash.sh` has been superseded by `initrd-flash` which loads a Linux image into RAM and then in turn writes to either eMMC or NVMe storage.
 `cw-flash-emmc.sh` replicates the functionality of `doflash.sh` by writing directly to eMMC storage in recovery mode, allow continuity with existing processes where that's still required.

## Usage

```
```
./cw-flash-emmc.sh
```
```
```
```
