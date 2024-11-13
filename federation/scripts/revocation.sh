#!/bin/bash

# Configuration
CERT_DIR="./_data/certs"
INDEX_FILE="${CERT_DIR}/ca/intermediate-ca/index.txt"
CA_CERT="${CERT_DIR}/ca/intermediate-ca/intermediate.crt"
CA_KEY="${CERT_DIR}/ca/intermediate-ca/private/intermediate.key"

# Default revocation reason
REASON="unspecified"
FOUND_CERT=false
ACTION="revoke"  # Default action

# Usage information
usage() {
    echo "Usage: $0 [--server servername] [--cert certificate_file] [--reason reason_code] [--unrevoke]"
    echo "Revokes or unrevokes an SSL certificate and updates the OCSP database"
    echo ""
    echo "Options:"
    echo "  --server     Server name (e.g., xmpp1)"
    echo "  --cert       Path to the certificate to revoke (alternative to --server)"
    echo "  --reason     Reason for revocation (optional):"
    echo "               unspecified (default)"
    echo "               keyCompromise"
    echo "               CACompromise"
    echo "               affiliationChanged"
    echo "               superseded"
    echo "               cessationOfOperation"
    echo "               certificateHold"
    echo "  --unrevoke   Removes the revocation status of the certificate"
    exit 1
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --server)
            SERVER_NAME="$2"
            if [[ ! "$SERVER_NAME" =~ ^xmpp[0-9]+$ ]]; then
                echo "Error: Server name must be in format 'xmpp<number>' (e.g., xmpp1)"
                usage
            fi
            CERTIFICATE="${CERT_DIR}/${SERVER_NAME}.crt"
            shift 2
            ;;
        --cert)
            CERTIFICATE="$2"
            shift 2
            ;;
        --reason)
            case "$2" in
                unspecified|keyCompromise|CACompromise|affiliationChanged|superseded|cessationOfOperation|certificateHold)
                    REASON="$2"
                    ;;
                *)
                    echo "Error: Invalid reason. See usage for valid reasons."
                    usage
                    ;;
            esac
            shift 2
            ;;
        --unrevoke)
            ACTION="unrevoke"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            ;;
    esac
done

# Validate input and files
if [ -z "$CERTIFICATE" ]; then
    echo "Error: Either --server or --cert must be specified"
    usage
fi

for file in "$CERTIFICATE" "$INDEX_FILE" "$CA_CERT" "$CA_KEY"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file not found: $file"
        exit 1
    fi
done

# Create backup
INDEX_BACKUP="${INDEX_FILE}.$(date +%Y%m%d%H%M%S).bak"
cp "$INDEX_FILE" "$INDEX_BACKUP"

# Get certificate serial number
SERIAL=$(openssl x509 -in "$CERTIFICATE" -noout -serial | cut -d'=' -f2)

# Create new index file
> "$INDEX_FILE.new"

# Read and process each line
while read -r line; do
    # Split the line into fields
    status=$(echo "$line" | cut -f1)
    expiry=$(echo "$line" | cut -f2)
    revocation=$(echo "$line" | cut -f3)
    serial=$(echo "$line" | cut -f4)
    filename=$(echo "$line" | cut -f5)
    subject=$(echo "$line" | cut -f6)

    if [ "$serial" = "$SERIAL" ]; then
        if [ "$ACTION" = "revoke" ]; then
            if [ "$status" = "R" ]; then
                echo "Error: Certificate is already revoked"
                rm "$INDEX_FILE.new"
                rm "$INDEX_BACKUP"
                exit 1
            fi
            # Create revoked entry
            REVOKE_DATE=$(date -u +%y%m%d%H%M%SZ)
            printf 'R\t%s\t%s,%s\t%s\t%s\t%s\n' \
                "$expiry" \
                "$REVOKE_DATE" \
                "$REASON" \
                "$serial" \
                "$filename" \
                "$subject" >> "$INDEX_FILE.new"
        else  # unrevoke
            if [ "$status" != "R" ]; then
                echo "Error: Certificate is not revoked"
                rm "$INDEX_FILE.new"
                rm "$INDEX_BACKUP"
                exit 1
            fi
            # Convert back to valid entry
            printf 'V\t%s\t\t%s\t%s\t%s\n' \
                "$expiry" \
                "$serial" \
                "$filename" \
                "$subject" >> "$INDEX_FILE.new"
        fi
        FOUND_CERT=true
    else
        # Not our certificate - keep original line
        echo "$line" >> "$INDEX_FILE.new"
    fi
done < "$INDEX_FILE"

if [ "$FOUND_CERT" = false ]; then
    echo "Error: Certificate not found in database"
    echo "Looking for serial: $SERIAL"
    rm "$INDEX_FILE.new"
    exit 1
fi

if mv "$INDEX_FILE.new" "$INDEX_FILE"; then
    if [ "$ACTION" = "revoke" ]; then
        echo "Certificate successfully revoked"
        echo "Reason: $REASON"
    else
        echo "Certificate successfully unrevoked"
    fi
    echo -e "\nTo verify the current status:"
    echo "openssl ocsp -url http://ocsp.localhost.example:8888 \\"
    echo "    -issuer ${CERT_DIR}/ca/intermediate-ca/intermediate.crt \\"
    echo "    -CAfile ${CERT_DIR}/$(basename "$CERTIFICATE" .crt)_chain.pem \\"
    echo "    -cert ${CERTIFICATE} \\"
    echo "    -text"
    echo -e "\nNote: The first OCSP status check may return the previous status."
    echo "      Run the check again if this happens - subsequent checks will show the current status."
    # Clean up backup file on success
    rm "$INDEX_BACKUP"
else
    echo "Error: Failed to ${ACTION} certificate"
    echo "Restoring database backup..."
    cp "$INDEX_BACKUP" "$INDEX_FILE"
    exit 1
fi