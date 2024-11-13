#!/bin/bash

# OCSP server configuration
# Defines where the OCSP responder will be accessible in the Docker network
OCSP_URL="http://ocsp.localhost.example:8888"

# Base directory for all certificate-related files
# All paths in this script will be relative to this directory
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

# Create the PKI directory structure:
# We only need:
# - root-ca: Root Certificate Authority files
# - intermediate-ca: Intermediate Certificate Authority files
# - ocsp-responder: OCSP responder certificates
mkdir -p "${CERT_DIR}/ca/root-ca/private" \
         "${CERT_DIR}/ca/intermediate-ca/private" \
         "${CERT_DIR}/ca/ocsp-responder"
chmod 700 "${CERT_DIR}/ca/root-ca/private" "${CERT_DIR}/ca/intermediate-ca/private"

# Initialize the certificate databases and serial number counters
# index.txt acts as a database of all certificates
# serial defines the next certificate serial number
echo -n > "${CERT_DIR}/ca/intermediate-ca/index.txt"
echo 1000 > "${CERT_DIR}/ca/intermediate-ca/serial"

# Generate the Root CA private key and certificate
# This is the top-level certificate authority that signs the intermediate CA
openssl genrsa -out "${CERT_DIR}/ca/root-ca/private/ca.key" 4096

openssl req -new -x509 -key "${CERT_DIR}/ca/root-ca/private/ca.key" \
    -out "${CERT_DIR}/ca/root-ca/ca.crt" -days 3650 \
    -subj "/C=GB/ST=London/L=London/O=Test Openfire/CN=Test Openfire Root CA"

# Generate the Intermediate CA private key and certificate signing request (CSR)
# The intermediate CA will be used to sign the server and OCSP responder certificates
openssl genrsa -out "${CERT_DIR}/ca/intermediate-ca/private/intermediate.key" 4096

openssl req -new -key "${CERT_DIR}/ca/intermediate-ca/private/intermediate.key" \
    -out "${CERT_DIR}/ca/intermediate-ca/intermediate.csr" \
    -subj "/C=GB/ST=London/L=London/O=Test Openfire/CN=Test Openfire Intermediate CA"

# Sign the Intermediate CA certificate with the Root CA
# The certificate includes:
# - CA capabilities (basicConstraints)
# - Permission to sign certificates (keyUsage)
# - Location of the OCSP responder (authorityInfoAccess)
openssl x509 -req -in "${CERT_DIR}/ca/intermediate-ca/intermediate.csr" \
    -CA "${CERT_DIR}/ca/root-ca/ca.crt" \
    -CAkey "${CERT_DIR}/ca/root-ca/private/ca.key" -CAcreateserial \
    -out "${CERT_DIR}/ca/intermediate-ca/intermediate.crt" -days 1825 \
    -extfile <(printf 'basicConstraints=critical,CA:true,pathlen:0\nkeyUsage=critical,digitalSignature,keyCertSign,cRLSign\nauthorityInfoAccess=OCSP;URI:%s' "$OCSP_URL")

# Function to generate a server certificate and add it to the certificate database
# Parameters:
#   $1: instance number (1, 2, or 3 for xmpp1/xmpp2/xmpp3)
generate_server_cert() {
    local instance=$1
    local server_name="xmpp${instance}"

    # Generate server private key and CSR
    openssl genrsa -out "${CERT_DIR}/${server_name}.key" 2048

    # Create OpenSSL config file for SAN support
    cat > "${CERT_DIR}/${server_name}.cnf" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = GB
ST = London
L = London
O = Test Openfire
CN = ${server_name}.localhost.example

[v3_req]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${server_name}.localhost.example
DNS.2 = *.${server_name}.localhost.example
EOF

    # Generate CSR with the config file
    openssl req -new -key "${CERT_DIR}/${server_name}.key" \
        -out "${CERT_DIR}/${server_name}.csr" \
        -config "${CERT_DIR}/${server_name}.cnf"

    # Create OpenSSL config for certificate signing
    cat > "${CERT_DIR}/${server_name}_sign.cnf" << EOF
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
authorityInfoAccess = OCSP;URI:${OCSP_URL}

[alt_names]
DNS.1 = ${server_name}.localhost.example
DNS.2 = *.${server_name}.localhost.example
EOF

    # Sign the server certificate with the Intermediate CA
    openssl x509 -req -in "${CERT_DIR}/${server_name}.csr" \
        -CA "${CERT_DIR}/ca/intermediate-ca/intermediate.crt" \
        -CAkey "${CERT_DIR}/ca/intermediate-ca/private/intermediate.key" -CAcreateserial \
        -out "${CERT_DIR}/${server_name}.crt" -days 365 \
        -extfile "${CERT_DIR}/${server_name}_sign.cnf"

    # Create the full certificate chain
    cat "${CERT_DIR}/${server_name}.crt" \
        "${CERT_DIR}/ca/intermediate-ca/intermediate.crt" \
        "${CERT_DIR}/ca/root-ca/ca.crt" > "${CERT_DIR}/${server_name}_chain.pem"

    # Add to certificate database
    SERIAL=$(openssl x509 -in "${CERT_DIR}/${server_name}.crt" -noout -serial | cut -d'=' -f2)
    SUBJECT=$(openssl x509 -in "${CERT_DIR}/${server_name}.crt" -noout -subject | cut -d'=' -f2-)
    printf 'V\t%s\t\t%s\tunknown\t%s\n' "$(date -u +%y%m%d%H%M%SZ)" "$SERIAL" "$SUBJECT" >> "${CERT_DIR}/ca/intermediate-ca/index.txt"

    # Clean up temporary config files
    rm -f "${CERT_DIR}/${server_name}.cnf" "${CERT_DIR}/${server_name}_sign.cnf"

    # Display the certificate's subject and SANs for verification
    echo "Certificate generated for ${server_name}:"
    openssl x509 -in "${CERT_DIR}/${server_name}.crt" -noout -subject -ext subjectAltName
}

# Generate the OCSP responder certificate
# This certificate will be used to sign OCSP responses
openssl genrsa -out "${CERT_DIR}/ca/ocsp-responder/ocsp.key" 2048

openssl req -new -key "${CERT_DIR}/ca/ocsp-responder/ocsp.key" \
    -out "${CERT_DIR}/ca/ocsp-responder/ocsp.csr" \
    -subj "/C=GB/ST=London/L=London/O=Test Openfire/CN=ocsp.example.com"

# Sign the OCSP responder certificate
# The certificate includes:
# - Non-CA status (basicConstraints)
# - OCSP signing capability (extendedKeyUsage)
openssl x509 -req -in "${CERT_DIR}/ca/ocsp-responder/ocsp.csr" \
    -CA "${CERT_DIR}/ca/intermediate-ca/intermediate.crt" \
    -CAkey "${CERT_DIR}/ca/intermediate-ca/private/intermediate.key" -CAcreateserial \
    -out "${CERT_DIR}/ca/ocsp-responder/ocsp.crt" -days 365 \
    -extfile <(printf 'basicConstraints=critical,CA:false\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=OCSPSigning')

# Get the list of server instances that exist
SERVER_INSTANCES=($(get_server_instances))

if [ ${#SERVER_INSTANCES[@]} -eq 0 ]; then
    echo "Error: No server directories found in ${XMPP_BASE_DIR}"
    exit 1
fi

echo "Found server directories for instances: ${SERVER_INSTANCES[*]}"

# Generate certificates for each existing server instance
for instance in "${SERVER_INSTANCES[@]}"; do
    echo "Generating certificates for xmpp${instance}"
    generate_server_cert "$instance"
done

# Verify the certificate chain for all generated certificates
# This ensures that all certificates are properly signed and trusted
echo "Verifying certificates..."
openssl verify -CAfile "${CERT_DIR}/ca/root-ca/ca.crt" "${CERT_DIR}/ca/intermediate-ca/intermediate.crt"

# Verify each server certificate
for instance in "${SERVER_INSTANCES[@]}"; do
    openssl verify -CAfile <(cat "${CERT_DIR}/ca/root-ca/ca.crt" "${CERT_DIR}/ca/intermediate-ca/intermediate.crt") \
        "${CERT_DIR}/xmpp${instance}.crt"
done

openssl verify -CAfile <(cat "${CERT_DIR}/ca/root-ca/ca.crt" "${CERT_DIR}/ca/intermediate-ca/intermediate.crt") \
    "${CERT_DIR}/ca/ocsp-responder/ocsp.crt"

printf '\nCertificate generation complete.'
printf '\nOCSP URL configured as: %s\n' "$OCSP_URL"
printf 'Generated certificates for servers: %s\n\n' "${SERVER_INSTANCES[*]}"
