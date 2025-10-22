#!/bin/sh


TIMEOUT_TIME=30

until $1; do
    echo "[!] command '$1' crashed with exit code $?, sleeping for $TIMEOUT_TIME"
    sleep $TIMEOUT_TIME
    echo "[!] respawning..."
    TIMEOUT_TIME=$(($TIMEOUT_TIME+30))
done
