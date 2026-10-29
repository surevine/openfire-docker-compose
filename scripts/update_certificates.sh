#!/bin/bash
# Regenerates the TLS stores committed under each environment's xmpp/**/conf/security directory:
#
#   truststore  Mozilla's root store (the CCADB list of roots trusted for websites, as shipped
#               in Firefox), plus the self-signed certificate of each federated peer.
#   keystore    A new self-signed certificate for the server's XMPP domain.
#
# client.truststore is left alone; it is empty in every environment.
#
# Run it from anywhere, then commit the changed stores. Requires curl, openssl and keytool.

set -euo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")"; pwd -P )"
ROOT="$SCRIPTPATH/.."

# Openfire's default store password (see conf/security.xml)
STOREPASS="changeit"
# The certificates are self-signed and only used in this test lab, so a long validity
# saves regenerating them every few years.
VALIDITY_DAYS=3650
CCADB_URL="https://ccadb.my.salesforce-sites.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites"

for cmd in curl openssl keytool; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed"
    exit 1
  fi
done

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

# Imports a PEM certificate into a store as a trusted certificate. keytool's output is shown
# only on failure: it warns about every SHA-1 signed root, which doesn't matter for a trust anchor.
trust() {
  local store=$1 alias=$2 cert=$3 output
  if ! output=$(keytool -importcert -noprompt -storetype JKS -keystore "$store" -storepass "$STOREPASS" \
      -alias "$alias" -file "$cert" 2>&1); then
    echo "Error: failed to import $cert as \"$alias\" into $store"
    echo "$output"
    exit 1
  fi
}

# Picks a readable alias for a CA certificate: its CN, else its OU, else its O.
ca_alias() {
  local subject
  subject=$(openssl x509 -noout -subject -nameopt sep_multiline,utf8,sname -in "$1")
  for attr in CN OU O; do
    local value
    value=$(echo "$subject" | sed -n "s/^ *$attr=//p" | head -1)
    if [ -n "$value" ]; then
      echo "$value"
      return
    fi
  done
  basename "$1" .pem
}

build_mozilla_truststore() {
  local store=$1
  echo "Downloading Mozilla's root store from CCADB"
  curl --fail --silent --show-error -o "$TEMPDIR/roots.pem" "$CCADB_URL"

  mkdir "$TEMPDIR/roots"
  awk -v dir="$TEMPDIR/roots" '
    /-----BEGIN CERTIFICATE-----/ { n++; file = sprintf("%s/%03d.pem", dir, n) }
    file { print > file }
    /-----END CERTIFICATE-----/ { close(file); file = "" }
  ' "$TEMPDIR/roots.pem"

  local count=0
  for cert in "$TEMPDIR"/roots/*.pem; do
    local alias
    alias=$(ca_alias "$cert")
    # Aliases are case-insensitive in JKS and some CAs share a name; disambiguate with the fingerprint.
    if keytool -list -keystore "$store" -storepass "$STOREPASS" -alias "$alias" &> /dev/null; then
      alias="$alias $(openssl x509 -noout -fingerprint -sha256 -in "$cert" | sed 's/.*=//; s/://g' | cut -c1-8)"
    fi
    trust "$store" "$alias" "$cert"
    count=$((count + 1))
  done
  echo "Imported $count root certificates"
}

# Generates a keystore holding a self-signed certificate for an XMPP domain, and exports the certificate.
# Parameters: domain, then any further DNS names for the subjectAltName extension.
generate_identity() {
  local domain=$1
  shift
  local san="dns:$domain,dns:*.$domain"
  for name in "$@"; do
    san="$san,dns:$name"
  done

  echo "Generating a self-signed certificate for $domain"
  keytool -genkeypair -noprompt -storetype JKS -keystore "$TEMPDIR/$domain.keystore" \
    -storepass "$STOREPASS" -keypass "$STOREPASS" -alias "${domain}_rsa" \
    -keyalg RSA -keysize 2048 -sigalg SHA256withRSA -validity "$VALIDITY_DAYS" \
    -dname "CN=$domain" -ext "SAN=$san" 2> /dev/null
  keytool -exportcert -rfc -keystore "$TEMPDIR/$domain.keystore" -storepass "$STOREPASS" \
    -alias "${domain}_rsa" -file "$TEMPDIR/$domain.crt" 2> /dev/null
}

# Installs a domain's keystore and a truststore that also trusts the given peer domains.
# Parameters: security directory (relative to the repository root), domain, then any peer domains.
install_stores() {
  local dir=$1 domain=$2
  shift 2
  cp "$TEMPDIR/$domain.keystore" "$ROOT/$dir/keystore"
  cp "$TEMPDIR/mozilla.truststore" "$ROOT/$dir/truststore"
  for peer in "$@"; do
    trust "$ROOT/$dir/truststore" "$peer" "$TEMPDIR/$peer.crt"
  done
  echo "Updated $dir"
}

build_mozilla_truststore "$TEMPDIR/mozilla.truststore"

generate_identity xmpp.localhost.example xmpp1.localhost.example xmpp2.localhost.example xmpp3.localhost.example
generate_identity otherxmpp.localhost.example
generate_identity xmpp1.localhost.example
generate_identity xmpp2.localhost.example

install_stores simple/xmpp/conf/security xmpp.localhost.example
install_stores proxy/xmpp/conf/security xmpp.localhost.example
for node in 1 2 3; do
  install_stores "cluster/xmpp/$node/conf/security" xmpp.localhost.example
  install_stores "cluster_mssql/xmpp/$node/conf/security" xmpp.localhost.example
  install_stores "cluster_with_federation/xmpp/$node/conf/security" xmpp.localhost.example otherxmpp.localhost.example
done
install_stores cluster_with_federation/xmpp/otherdomain/conf/security otherxmpp.localhost.example xmpp.localhost.example
install_stores federation/xmpp/1/conf/security xmpp1.localhost.example xmpp2.localhost.example
install_stores federation/xmpp/2/conf/security xmpp2.localhost.example xmpp1.localhost.example
