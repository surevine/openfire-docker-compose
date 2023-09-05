#!/bin/bash
##### Copy a certificate from an Openfire identity store to an Openfire truststore
set -euo pipefail


# Gather parameters and check for errors
IDENTITY_STORE=$1
TRUST_STORE=$2

if [ -z "$IDENTITY_STORE" ] || [ -z "$TRUST_STORE" ]; then
    echo "Usage: $0 <identity store> <trust store>"
    exit 1
fi

if [ ! -f "$IDENTITY_STORE" ]; then
    echo "Identity store not found: $IDENTITY_STORE"
    exit 1
fi

if [ ! -f "$TRUST_STORE" ]; then
    echo "Trust store not found: $TRUST_STORE"
    exit 1
fi

IDENTITY_STORE=${readlink -f "$IDENTITY_STORE"}
TRUST_STORE=${readlink -f "$TRUST_STORE"}

pushd "$(mktemp -d)" || exit


# Check that there's only 1 alias in the identity store
ALIAS_COUNT=$(keytool -list -keystore "$IDENTITY_STORE" -storepass changeit | grep --count "Alias name:")
if [ "$ALIAS_COUNT" -ne 1 ]; then
    echo "Expected 1 alias in identity store, found $ALIAS_COUNT"
    exit 1
fi


# Get Alias Name from identity store
ALIAS_NAME=$(keytool -list -keystore "$IDENTITY_STORE" -storepass changeit | grep "Alias name:" | awk '{print $3}')


# Get DER from identity store
keytool -exportcert -alias "$ALIAS_NAME" -keystore "$IDENTITY_STORE" -storepass changeit -file openfire.der


# Convert DER to PEM
openssl x509 -inform der -in openfire.der -out openfire.pem


# Import PEM into trust store
keytool -importcert -alias "$ALIAS_NAME" -keystore "$TRUST_STORE" -storepass changeit -file openfire.pem -noprompt