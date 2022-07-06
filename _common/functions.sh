#!/bin/bash

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

check_deps () {
    if ! which docker > /dev/null; then
        echo "ERROR: docker is not installed."
        exit 1
    fi
    if ! docker compose version > /dev/null; then
        echo "ERROR: docker compose is not installed, or is too old."
        exit 1
    fi
}