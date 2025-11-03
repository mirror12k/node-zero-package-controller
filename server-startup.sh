#!/bin/bash
set -e

SERVER_ROOT=$PWD

run_package() {
    local PACKAGE_DIR="$1"
    local PACKAGE_USER="$2"
    local PACKAGE_NAME="$3"
    shift 3                          # everything left in "$@" are extra args
    local EXTRA_ARGS=("$@")

    local INPUT_PIPE="/dev/null"
    local LOG_FILE="/var/log/${PACKAGE_NAME}_server/server.log"

    echo "🚀 Starting ${PACKAGE_DIR} as ${USER}..."
    echo "----------------------------------------------"
    echo "Working directory: ${SERVER_ROOT}/${PACKAGE_DIR}"
    echo "Log file:          ${LOG_FILE}"
    echo "Input pipe:      ${INPUT_PIPE}"
    echo "----------------------------------------------"

    cd "${PACKAGE_DIR}"

    git pull

    "${SERVER_ROOT}/daemonize.sh" "$USER" "./run-package.sh $PACKAGE_USER $PACKAGE_NAME ${EXTRA_ARGS[@]}" \
        "$LOG_FILE" "$INPUT_PIPE"

    echo "Daemon started successfully!"
}

run_package "$SERVER_ROOT/deployable-invidious-package" "invd_runner" "invidious"
run_package "$SERVER_ROOT/deployable-materialious-package" "matl_runner" "materialious" "http://localhost:3000"
run_package "$SERVER_ROOT/deployable-jellyfin-package" "jell_runner" "jellyfin"

