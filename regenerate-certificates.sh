#!/bin/bash

# Configuration Variables
CA_CERT="docker/kinesis/ssl/ca-crt.pem"     # Path for the new CA certificate
CA_KEY="docker/kinesis/ssl/ca-key.pem"      # Path for the new CA private key
SERVER_KEY="docker/kinesis/ssl/server-key.pem"  # Keep existing server private key
SERVER_CSR="docker/kinesis/ssl/server-csr.pem"  # Path for the new server CSR
SERVER_CERT="docker/kinesis/ssl/server-crt.pem" # Path for the new server certificate
DAYS_CA=$(( (2040 - $(date +%Y)) * 365 ))  # Number of days until the year 2040 for CA
DAYS_SRV=$(( (2040 - $(date +%Y)) * 365 )) # Number of days until the year 2040 for server certificate

# Generate new CA
echo "Generating new CA..."
openssl req -new -x509 -days $DAYS_CA -keyout $CA_KEY -out $CA_CERT -subj "/C=US/ST=NY/L=New York/O=Kinesalite/CN=Kinesalite CA" -newkey rsa:4096 -sha256

# Ensure the server key exists or generate a new one
if [ ! -f "$SERVER_KEY" ]; then
    echo "Server key does not exist, generating a new one..."
    openssl genpkey -algorithm RSA -out $SERVER_KEY -pkeyopt rsa_keygen_bits:4096
fi

# Generate a new CSR for the server
echo "Generating new server CSR..."
openssl req -new -key $SERVER_KEY -out $SERVER_CSR -config docker/kinesis/ssl/san.cnf

# Sign the new server CSR with the new CA to generate a new server certificate
echo "Generating new server certificate..."
openssl x509 -req -in $SERVER_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CERT -days $DAYS_SRV -sha256 -extfile docker/kinesis/ssl/san.cnf -extensions v3_ca

# Clean up CSR as it's no longer needed
rm $SERVER_CSR

# Inform the user
echo "New CA and server certificate generated."
echo "CA certificate at: $CA_CERT"
echo "CA private key at: $CA_KEY"
echo "Server certificate at: $SERVER_CERT"