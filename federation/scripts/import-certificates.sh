#!/bin/bash

# Default password for all keystores and truststores
# This is Openfire's default password - changing it would require updating security.xml
KEYSTORE_PASSWORD="changeit"

# Base directory where certificates were generated
# This should match the CERT_DIR from the certificate generation script
CERT_DIR="./_data/certs"
XMPP_BASE_DIR="./_data/xmpp"

# Function to check which server directories exist
get_server_instances() {
    local instances=()
    # Look for numbered directories in the xmpp base directory
    for dir in "$XMPP_BASE_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            # Extract the number from the directory name
            local num=$(basename "$dir")
            if [[ "$num" =~ ^[0-9]+$ ]]; then
                instances+=("$num")
            fi
        fi
    done
    echo "${instances[@]}"
}

# Function to import certificates and set up keystores/truststores for one Openfire instance
# Parameters:
#   $1: instance number (1, 2, or 3 for xmpp1/xmpp2/xmpp3)
import_certificates() {
    local instance=$1
    local server_name="xmpp${instance}"

    # Directory where Openfire expects to find its certificates
    local conf_dir="_data/xmpp/${instance}/conf/security"

    echo "Importing certificates for ${server_name}..."

    # Ensure the security directory exists
    mkdir -p "${conf_dir}"

    # Remove any existing keystore to start fresh
    rm -f "${conf_dir}/keystore"

    echo "Creating new keystore for ${server_name}"
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
        -in "${CERT_DIR}/${server_name}.crt" \
        -inkey "${CERT_DIR}/${server_name}.key" \
        -chain \
        -CAfile "${CERT_DIR}/${server_name}_chain.pem" \
        -name "${server_name}.localhost.example" \
        -out "${CERT_DIR}/${server_name}.p12" \
        -password "pass:${KEYSTORE_PASSWORD}"

    # Import the PKCS12 file into the keystore
    keytool -importkeystore \
        -deststorepass "${KEYSTORE_PASSWORD}" \
        -destkeypass "${KEYSTORE_PASSWORD}" \
        -destkeystore "${conf_dir}/keystore" \
        -srckeystore "${CERT_DIR}/${server_name}.p12" \
        -srcstoretype PKCS12 \
        -srcstorepass "${KEYSTORE_PASSWORD}" \
        -alias "${server_name}.localhost.example"

    # Create or update truststore
    # truststore - used by the server to verify other servers
    if [ ! -f "${conf_dir}/truststore" ]; then
        echo "Creating new truststore for ${server_name}"
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

    echo "Certificate import completed for ${server_name}"
}

# Main script execution
echo "Starting certificate import process..."

# Get the list of server instances that exist
SERVER_INSTANCES=($(get_server_instances))

if [ ${#SERVER_INSTANCES[@]} -eq 0 ]; then
    echo "Error: No server directories found in ${XMPP_BASE_DIR}"
    exit 1
fi

echo "Found server directories for instances: ${SERVER_INSTANCES[*]}"

# Import certificates for each existing server instance
for instance in "${SERVER_INSTANCES[@]}"; do
    echo "Importing certificates for xmpp${instance}"
    import_certificates "$instance"
done

# Clean up temporary PKCS12 files that were created during the import process
rm -f "${CERT_DIR}"/*.p12

# Display commands that can be used to verify the keystore contents
echo -e "\nTo verify the keystores, run:"
for instance in "${SERVER_INSTANCES[@]}"; do
    echo "keytool -list -keystore _data/xmpp/${instance}/conf/security/keystore -storepass ${KEYSTORE_PASSWORD}"
    echo "keytool -list -keystore _data/xmpp/${instance}/conf/security/truststore -storepass ${KEYSTORE_PASSWORD}"
done