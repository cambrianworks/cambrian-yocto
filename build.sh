#!/bin/bash

###############################################################################
#
# Usage:
# ./build.sh <target>
#
# Initiates a build of the gigrouter image for the specified target. Options
# are:
#
#   gigcompute              - Cambrian Work's official GigComputer hardware
#                             consisting of Nvidia's AGX Orin SoM on a custom
#                             carrier PCB.
#
#   gigrouter               - Cambrian Work's official GigRouter hardware
#                             consisting of Nvidia's AGX Orin SoM on a custom
#                             carrier PCB.
#
#   gigrouter-nano-devkit   - Nvidia's Orino Nano development board. Warning:
#                             The hardware is electrically distinct from the
#                             GigRouter product and isn't a suitable target for
#                             running Cambrian Works applications. It's included
#                             here for testing the Yocto build process and
#                             validating images against a known reference board.
#
###############################################################################

# Execution steps
readonly do_setup_kas=y
readonly do_checkout_layers=y
readonly do_build=y

# Variables
readonly KAS_DIRECTORY=kas
readonly GIGROUTER=gigrouter
readonly GIGCOMPUTE=gigcompute
readonly GIGROUTER_NANO_DEVKIT=gigrouter-nano-devkit
readonly GIGCOMPUTE_KAS_CONFIG=$KAS_DIRECTORY/gigcompute-kas-config.yml
readonly GIGROUTER_KAS_CONFIG=$KAS_DIRECTORY/gigrouter-kas-config.yml
readonly GIGROUTER_NANO_DEVKIT_KAS_CONFIG=$KAS_DIRECTORY/gigrouter-nano-devkit-kas-config.yml

msg() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)]: $@" >&2
}

build() {
    msg "Initiating build with configuration: $@"
    kas-container build $@
}

checkout_layers() {
    kas checkout $@
}

clean() {
    msg "Deleting build artifacts"
    if command -v "deactivate" &> /dev/null; then
        deactivate
    fi
    rm -rf build
    rm -rf repos
    rm -rf venv
}

setup_kas() {
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
}

usage() {
    msg "Inavlid parameters
    Usage:
    ./build.sh <target | clean>
    <target>   -   Hardware platform to target build. Options:

                   gigcompute            - Cambrian Works official GigComute hardare.
                   gigrouter             - Cambrian Works official GigRouter hardware.
                   gigrouter-nano-devkit - Nvidia reference board.
                   clean                 - Exit venv shell (if running) and delete
                                           build artifacts."
}

###############################################################################
# Execute script
###############################################################################

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

configfile=$GIGROUTER_KAS_CONFIG
if [ "$1" == $GIGROUTER ]; then
    configfile=$GIGROUTER_KAS_CONFIG
elif [ "$1" == $GIGCOMPUTE ]; then
    configfile=$GIGCOMPUTE_KAS_CONFIG
elif [ "$1" == $GIGROUTER_NANO_DEVKIT ]; then
    configfile=$GIGROUTER_NANO_DEVKIT_KAS_CONFIG
elif [ "$1" == "clean" ]; then
    read -p "Cleaning build artifacts. Press ENTER to continue (c to cancel) ..." entry
    if [ ! -z $entry ]; then
        if [ $entry = "c" ]; then
            msg "Clean cancelled"
            exit 0
        fi
    fi
    clean
    exit 0
else
    usage
    exit 1
fi
msg "Building for $1"

if [ $do_setup_kas = "y" ]; then
    setup_kas $configfile
fi

if [ $do_checkout_layers = "y" ]; then
    checkout_layers $configfile
fi

if [ $do_build = "y" ]; then
    build $configfile
fi

msg "Build complete"
exit 0

###############################################################################
# End execution
###############################################################################
