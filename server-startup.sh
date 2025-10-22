#!/bin/bash
set -e

SERVER_ROOT=$PWD

run_package() {
    local PACKAGE_DIR="$1"
    local PACKAGE_USER="$2"
    local PACKAGE_NAME="$3"
    local INPUT_PIPE="/dev/null"
    local LOG_FILE="/var/log/${PACKAGE_NAME}_server/server.log"

    echo "🚀 Starting ${PACKAGE_DIR} as ${USER}..."
    echo "----------------------------------------------"
    echo "Working directory: ${SERVER_ROOT}/${PACKAGE_DIR}"
    echo "Log file:          ${LOG_FILE}"
    echo "Input pipe:      ${INPUT_PIPE}"
    echo "----------------------------------------------"

    cd "${SERVER_ROOT}/${PACKAGE_DIR}"

    "${SERVER_ROOT}/daemonize.sh" "$USER" "./run-package.sh $PACKAGE_USER $PACKAGE_NAME" \
        "$LOG_FILE" "$INPUT_PIPE"

    echo "Daemon started successfully!"
}

run_package "$SERVER_ROOT/deployable-invidious-package" "invd_runner" "invidious"
run_package "$SERVER_ROOT/deployable-jellyfin-package" "jell_runner" "jellyfin"

