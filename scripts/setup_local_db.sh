#!/bin/bash

mkdir -p .dynamodb
cd .dynamodb

if [ ! -f DynamoDBLocal.jar ]; then
    echo "DynamoDBLocal.jar not found. Downloading..."
    
    # Clean up
    rm -f dynamodb_local_latest.tar.gz

    # Try wget
    if command -v wget >/dev/null 2>&1; then
        echo "Attempting download with wget..."
        wget -v https://d1.awsstatic.com/dynamodb/dynamodb_local_latest.tar.gz
    fi
    
    # Try curl if file still missing
    if [ ! -f dynamodb_local_latest.tar.gz ]; then
        if command -v curl >/dev/null 2>&1; then
            echo "Attempting download with curl..."
            curl -L -o dynamodb_local_latest.tar.gz https://d1.awsstatic.com/dynamodb/dynamodb_local_latest.tar.gz
        fi
    fi

    # Verify
    if [ ! -f dynamodb_local_latest.tar.gz ]; then
        echo "Error: Download failed. Please manually download:"
        echo "https://d1.awsstatic.com/dynamodb/dynamodb_local_latest.tar.gz"
        echo "and check for network restrictions."
        exit 1
    fi

    echo "Extracting..."
    tar -xzf dynamodb_local_latest.tar.gz
fi

echo "Starting DynamoDB Local on port 8000..."
echo "Press Ctrl+C to stop."
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -port 8000
