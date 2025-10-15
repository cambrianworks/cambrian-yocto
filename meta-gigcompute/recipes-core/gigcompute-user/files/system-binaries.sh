#!/bin/bash

# Add system binaries to PATH to allow users
# to exeute utilities associated with hardware
# interfaces (e.g., NIC configuration, I2C bus etc)
case ":$PATH:" in
    *:/usr/sbin:*) ;;
    *) export PATH=$PATH:/usr/sbin ;;
esac

