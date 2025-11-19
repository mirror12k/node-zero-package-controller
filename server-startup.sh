#!/bin/bash
set -e

SERVER_ROOT=$PWD

run_package() {
    local PACKAGE_DIR="$1"
    local PACKAGE_USER="$2"
    local PACKAGE_NAME="$3"

    local INPUT_PIPE="/dev/null"
    local LOG_FILE="/var/log/${PACKAGE_NAME}_server/server.log"
    local ENVFILE="${SERVER_ROOT}/.envfile.${PACKAGE_NAME}"

    echo "🚀 Starting ${PACKAGE_DIR} as ${USER}..."
    echo "----------------------------------------------"
    echo "Working directory: ${PACKAGE_DIR}"
    echo "Log file:          ${LOG_FILE}"
    echo "Input pipe:        ${INPUT_PIPE}"
    echo "Environment file:  ${ENVFILE}"
    echo "----------------------------------------------"

    cd "${PACKAGE_DIR}"

    git pull

    # Create envfile if it doesn't exist
    if [ ! -f "$ENVFILE" ]; then
        touch "$ENVFILE"
        echo "Created empty envfile: $ENVFILE"
    fi

    # Ensure log directory exists
    local LOG_DIR=$(dirname "$LOG_FILE")
    mkdir -p "$LOG_DIR"

    # Run docker command in background (daemonized) with input/output redirection
    nohup docker run --privileged --name "${PACKAGE_NAME}-container" --rm \
        --env-file "$ENVFILE" \
        -v "$(pwd)/${PACKAGE_NAME}:/app:ro" \
        -v "/${PACKAGE_NAME}:/${PACKAGE_NAME}" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -w "/app" -i docker:cli "sh" "/app/run.sh" \
        < "$INPUT_PIPE" >> "$LOG_FILE" 2>&1 &

    local DOCKER_PID=$!
    echo "Package ${PACKAGE_NAME} started in background (PID: $DOCKER_PID)"

    cd "${SERVER_ROOT}"
}

run_package "$SERVER_ROOT/deployable-invidious-package" "invd_runner" "invidious"
run_package "$SERVER_ROOT/deployable-materialious-package" "matl_runner" "materialious"
run_package "$SERVER_ROOT/deployable-jellyfin-package" "jell_runner" "jellyfin"
run_package "$SERVER_ROOT/deployable-caddy-proxy-package" "caddy_runner" "caddy"
run_package "$SERVER_ROOT/deployable-shinobi-package" "shinobi_runner" "shinobi"
run_package "$SERVER_ROOT/deployable-n8n-package" "n8n_runner" "n8n"
run_package "$SERVER_ROOT/deployable-openssh-package" "openssh_runner" "openssh"

