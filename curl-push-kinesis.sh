#!/bin/bash

# Configuration
AWS_ACCESS_KEY_ID="root"
AWS_SECRET_ACCESS_KEY="root"
AWS_REGION="us-east-1"
SERVICE="kinesis"
HOST="kinesalite:4567"
ENDPOINT="https://$HOST"
STREAM_NAME="curl-test-stream"
PARTITION_KEY="123"
DATA="$(echo -n '{"message": "hello"}' | base64)"

# Step 1: Create canonical request
METHOD="POST"
CANONICAL_URI="/"
CANONICAL_QUERYSTRING=""
CANONICAL_HEADERS="content-type:application/x-amz-json-1.1\nhost:$HOST\nx-amz-target:Kinesis_20131202.PutRecord"
SIGNED_HEADERS="content-type;host;x-amz-target"
PAYLOAD_HASH=$(echo -n '{"StreamName":"'"$STREAM_NAME"'","Data":"'"$DATA"'","PartitionKey":"'"$PARTITION_KEY"'"}' | openssl dgst -sha256 | sed 's/^.* //')
CANONICAL_REQUEST="$METHOD\n$CANONICAL_URI\n$CANONICAL_QUERYSTRING\n$CANONICAL_HEADERS\n\n$SIGNED_HEADERS\n$PAYLOAD_HASH"

# Step 2: Create string to sign
ALGORITHM="AWS4-HMAC-SHA256"
REQUEST_DATE=$(date -u "+%Y%m%dT%H%M%SZ")
DATE=$(date -u "+%Y%m%d")
CREDENTIAL_SCOPE="$DATE/$AWS_REGION/$SERVICE/aws4_request"
STRING_TO_SIGN="$ALGORITHM\n$REQUEST_DATE\n$CREDENTIAL_SCOPE\n$(echo -n "$CANONICAL_REQUEST" | openssl dgst -sha256 | sed 's/^.* //')"

# Step 3: Calculate the signature
SIGNING_KEY=$(echo -n "AWS4$AWS_SECRET_ACCESS_KEY" | openssl dgst -sha256 -hmac "AWS4$AWS_SECRET_ACCESS_KEY" -hex | sed 's/^.* //')
SIGNING_KEY=$(echo -n "$DATE" | openssl dgst -sha256 -mac HMAC -macopt hexkey:$SIGNING_KEY -hex | sed 's/^.* //')
SIGNING_KEY=$(echo -n "$AWS_REGION" | openssl dgst -sha256 -mac HMAC -macopt hexkey:$SIGNING_KEY -hex | sed 's/^.* //')
SIGNING_KEY=$(echo -n "$SERVICE" | openssl dgst -sha256 -mac HMAC -macopt hexkey:$SIGNING_KEY -hex | sed 's/^.* //')
SIGNATURE=$(echo -n "aws4_request" | openssl dgst -sha256 -mac HMAC -macopt hexkey:$SIGNING_KEY -hex | sed 's/^.* //')
SIGNATURE=$(echo -n "$STRING_TO_SIGN" | openssl dgst -sha256 -mac HMAC -macopt hexkey:$SIGNING_KEY -hex | sed 's/^.* //')

# Step 4: Add signing information to the request
AUTHORIZATION_HEADER="$ALGORITHM Credential=$AWS_ACCESS_KEY_ID/$CREDENTIAL_SCOPE, SignedHeaders=$SIGNED_HEADERS, Signature=$SIGNATURE"

# Final: Make the request
curl --verbose --trace-config all -X POST "$ENDPOINT" \
    -H "Content-Type: application/x-amz-json-1.1" \
    -H "X-Amz-Target: Kinesis_20131202.PutRecord" \
    -H "Authorization: $AUTHORIZATION_HEADER" \
    -H "X-Amz-Date: $REQUEST_DATE" \
    -H "Host: $HOST" \
    --data '{"StreamName":"'"$STREAM_NAME"'","Data":"'"$DATA"'","PartitionKey":"'"$PARTITION_KEY"'"}' \
    --cacert ./combined-ca-bundle.pem
