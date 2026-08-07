#!/bin/bash

###############################################################################
#
# Usage:
# ./build.sh <target>
#
# Initiates a build of the Cambrian Works image for the specified target.
#
###############################################################################

# Execution steps
readonly do_setup_kas=y
readonly do_checkout_layers=y
readonly do_build=y

# Variables
readonly KAS_DIRECTORY=kas
readonly KEYS_DIRECTORY=keys
readonly TARGET_CONFIGS_PATH=config/target_configs.json
readonly KEYS=("$KEYS_DIRECTORY/cambrian-works.cert.pem.iron"
               "$KEYS_DIRECTORY/private/ca.key.pem.iron"
               "$KEYS_DIRECTORY/private/cambrian-works.key.pem.iron")

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
    msg "Deleting decrypted keys"
    for key in "${KEYS[@]}"; do
        rm -rf "${key%.iron}"
    done

    msg "Deleting build artifacts"
    if command -v "deactivate" &> /dev/null; then
        deactivate
    fi
    rm -rf build
    rm -rf repos
    rm -rf venv
}

decrypt_keys() {
    msg "Decrypting keys"

    for key in "${KEYS[@]}"; do
        if [[ -f "${key%.*}" ]]; then
            msg "Key already decrypted, skipping: $key"
            continue
        fi
        ironhide file decrypt $key || { msg "Failed to decrypt: $key"; exit 1; }
    done
}

get_target_include_keys() {
    targetFound=$(jq -r --arg key "$1" 'any(.targets[]; has($key))' $TARGET_CONFIGS_PATH)
    if [ "$targetFound" != "true" ]; then
        msg "Failed to locate target $1 in $TARGET_CONFIGS_PATH"
        exit 1
    fi
    includeKeys=$(jq -r --arg key "$1" '.targets[] | select(has($key))[$key].includeKeys' $TARGET_CONFIGS_PATH)
    if [ "$includeKeys" == "true" ]; then
        echo "true"
    else
        # This case would also catch any other falsey value, such
        # as if the key was absent. All such cases can safely be
        # converted into an explicit "false" and still honour the
        # intent of the attribute.
        echo "false"
    fi
}

get_target_config_file() {
    targetFound=$(jq -r --arg key "$1" 'any(.targets[]; has($key))' $TARGET_CONFIGS_PATH)
    if [ "$targetFound" != "true" ]; then
        msg "Failed to locate target $1 in $TARGET_CONFIGS_PATH"
        exit 1
    fi
    configFile=$(jq -r --arg key "$1" '.targets[] | select(has($key))[$key].config' $TARGET_CONFIGS_PATH)
    if [ -n "$configFile" ] && [ "$configFile" != "null" ]; then
        echo $configFile
    else
        msg "Invalid config file value for target $1: $configFile"
        exit 1
    fi
}

print_targets() {
    msg "Hardware targets supported by configuration:"
    echo "-----------------------------------------------"
    jq -r '.targets[] | to_entries[] | "\(.key)\t\(.value.description)"' $TARGET_CONFIGS_PATH | \
    while IFS=$'\t' read key description; do
        echo "Target:       $key"
        echo "Description:  $description"
        echo "-----------------------------------------------"
    done
}

setup_kas() {
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
}

usage() {
    msg "
    Usage:
    ./build.sh <--target | --list | --clean | --help>
        -t|--target - Hardware platform to target build.

        -c|--clean  - Exit venv shell (if running) and delete
                      build artifacts.

        -l|--list   - Lists the target hardware specified in
                      the targets configuration.

        -h|--help   - Display help information"
}

validate_config() {
    msg "Validating $TARGET_CONFIGS_PATH"
    if jq -e 'has("targets")' $TARGET_CONFIGS_PATH > /dev/null; then
        if jq -e '.targets | type != "array"' $TARGET_CONFIGS_PATH > /dev/null; then
            msg "Invalid type for 'targets' key"
            exit 1
        fi
        if jq -e '.targets | length == 0' $TARGET_CONFIGS_PATH > /dev/null; then
            msg "Content of 'targets' is empty"
            exit 1
        fi
        msg "Targets config validated"
    else
        msg "targets key absent in $TARGET_CONFIGS_PATH"
        exit 1
    fi
}

###############################################################################
# Execute script
###############################################################################

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

target=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--clean)
            read -p "Cleaning build artifacts. Press ENTER to continue (c to cancel) ..." entry
            if [ ! -z $entry ]; then
                if [ $entry = "c" ]; then
                    msg "Clean cancelled"
                    exit 0
                fi
            fi
            clean
            exit 0
            ;;
        -l|--list)
            print_targets
            exit 0
            ;;
        -t|--target)
            target=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            shift 1
            ;;
    esac
done

if [[ -z "$target" ]]; then
    msg "Target not specified"
    exit 1
fi

if [ ! -f "$TARGET_CONFIGS_PATH" ]; then
    msg "Failed to locate target configs: $TARGET_CONFIGS_PATH"
    exit 1
fi
validate_config

configFile=$KAS_DIRECTORY/$(get_target_config_file $target)
includeKeys=$(get_target_include_keys $target)

msg "Building $target"
msg "Build configuration: $configFile"
msg "Including keys: $includeKeys"

if [ "$includeKeys" == "true" ]; then
    decrypt_keys
fi

if [ $do_setup_kas = "y" ]; then
    setup_kas $configFile
fi

if [ $do_checkout_layers = "y" ]; then
    checkout_layers $configFile
fi

if [ $do_build = "y" ]; then
    build $configFile
fi

msg "Build complete"
exit 0

###############################################################################
# End execution
###############################################################################
