#!/bin/bash

# Default password for all keystores and truststores
# This is Openfire's default password - changing it would require updating security.xml
KEYSTORE_PASSWORD="changeit"

# Base directory where certificates were generated
# This should match the CERT_DIR from the certificate generation script
CERT_DIR="./_data/certs"

# Function to import certificates and set up keystores/truststores for one Openfire instance
# Parameters:
#   $1: instance number (1 or 2 for xmpp1/xmpp2)
import_certificates() {
    local instance=$1

    # Directory where Openfire expects to find its certificates
    local conf_dir="_data/xmpp/${instance}/conf/security"

    echo "Importing certificates for Openfire instance ${instance}..."

    # Ensure the security directory exists
    mkdir -p "${conf_dir}"

    # Remove any existing keystore to start fresh
    rm -f "${conf_dir}/keystore"

    echo "Creating new keystore for instance ${instance}"
    # Create a new empty keystore by generating and immediately deleting a temporary keypair
    # This ensures the keystore is properly initialized with the correct format
    keytool -genkeypair \
        -keystore "${conf_dir}/keystore" \
        -storepass "${KEYSTORE_PASSWORD}" \
        -keypass "${KEYSTORE_PASSWORD}" \
        -alias "default" \
        -dname "CN=temporary" \
        -keyalg RSA \
        -validity 1
    # Remove the temporary keypair, leaving an empty keystore
    keytool -delete \
        -alias "default" \
        -keystore "${conf_dir}/keystore" \
        -storepass "${KEYSTORE_PASSWORD}"

    # Import the server's certificate and private key
    # First convert them to PKCS12 format which can be imported into a Java keystore
    echo "Importing server certificate and private key..."
    openssl pkcs12 -export \
        -in "${CERT_DIR}/server${instance}.crt" \
        -inkey "${CERT_DIR}/server${instance}.key" \
        -chain \
        -CAfile "${CERT_DIR}/chain${instance}.pem" \
        -name "xmpp${instance}.localhost.example" \
        -out "${CERT_DIR}/server${instance}.p12" \
        -password "pass:${KEYSTORE_PASSWORD}"

    # Import the PKCS12 file into the keystore
    keytool -importkeystore \
        -deststorepass "${KEYSTORE_PASSWORD}" \
        -destkeypass "${KEYSTORE_PASSWORD}" \
        -destkeystore "${conf_dir}/keystore" \
        -srckeystore "${CERT_DIR}/server${instance}.p12" \
        -srcstoretype PKCS12 \
        -srcstorepass "${KEYSTORE_PASSWORD}" \
        -alias "xmpp${instance}.localhost.example"

    # Create or update truststore
    # truststore - used by the server to verify other servers
    if [ ! -f "${conf_dir}/truststore" ]; then
        echo "Creating new truststore for instance ${instance}"
        # Initialize a new truststore with a dummy entry
        keytool -importpass \
            -keystore "${conf_dir}/truststore" \
            -storepass "${KEYSTORE_PASSWORD}" \
            -storetype JKS \
            -alias "init" \
            -noprompt
    fi

    # Add our CA certificates to truststore
    # We preserve existing entries to maintain trust for other certificates
    echo "Adding CA certificates to truststore..."

    # Import root CA if not already present
    # grep -q checks if the alias already exists in the store
    if ! keytool -list -keystore "${conf_dir}/truststore" -storepass "${KEYSTORE_PASSWORD}" | grep -q "root-ca"; then
        keytool -import -noprompt \
            -keystore "${conf_dir}/truststore" \
            -storepass "${KEYSTORE_PASSWORD}" \
            -alias "root-ca" \
            -file "${CERT_DIR}/ca/root-ca/ca.crt"
        echo "Added root CA to truststore"
    else
        echo "Root CA already exists in truststore"
    fi

    # Import intermediate CA if not already present
    if ! keytool -list -keystore "${conf_dir}/truststore" -storepass "${KEYSTORE_PASSWORD}" | grep -q "intermediate-ca"; then
        keytool -import -noprompt \
            -keystore "${conf_dir}/truststore" \
            -storepass "${KEYSTORE_PASSWORD}" \
            -alias "intermediate-ca" \
            -file "${CERT_DIR}/ca/intermediate-ca/intermediate.crt"
        echo "Added intermediate CA to truststore"
    else
        echo "Intermediate CA already exists in truststore"
    fi

    echo "Certificate import completed for instance ${instance}"
}

# Main script execution

echo "Starting certificate import process..."

# Import certificates for both Openfire instances
import_certificates 1
import_certificates 2

# Clean up temporary PKCS12 files that were created during the import process
rm -f "${CERT_DIR}"/*.p12

# Display commands that can be used to verify the keystore contents
echo -e "\nTo verify the keystores, run:"
echo "keytool -list -keystore _data/xmpp/1/conf/security/keystore -storepass ${KEYSTORE_PASSWORD}"
echo "keytool -list -keystore _data/xmpp/1/conf/security/truststore -storepass ${KEYSTORE_PASSWORD}"