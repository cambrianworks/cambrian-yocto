## Build Instructions

### Setup Kas

```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Setup Layers

```
kas checkout
```

### Build Image

```
kas-container build
```

### Flashing Image

Image is found at: `./build/tmp/deploy/images/gigrouter/demo-image-base-gigrouter.rootfs-[timestamp].tegraflash.tar.gz`

Extract that archive on a pi connected to the gigrouter.
Copy DTBs from `meta-tegra/recipes-kernel/gigrouter-devicetree/files` into the directory where the flashing archive was extracted.
This should get done by yocto but I haven't figured out how to do it yet (this is why there are dtbs everywhere).

Verify GR is in recovery with `lsusb` and then run `sudo ./doflash.sh`.
