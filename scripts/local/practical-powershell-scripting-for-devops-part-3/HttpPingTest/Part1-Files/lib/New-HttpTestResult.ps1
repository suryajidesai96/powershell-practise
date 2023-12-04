#!/bin/bash

New_HttpTestResult() {
    url=$1
    name=$2

    Method="GET"

    start_time=$(date +%s%N)
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    end_time=$(date +%s%N)

    duration=$((($end_time - $start_time) / 1000000))

    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    status_code=$(echo "$response" | tr -d '\n')

    result="{\"name\":\"$name\",\"status_code\":\"$status_code\",\"status_description\":\"\",\"responsetime_ms\":\"$duration\",\"timestamp\":\"$timestamp\"}"

    echo "$result"
}

# Example usage:
url="https://example.com"
name="TestName"
result=$(New_HttpTestResult "$url" "$name")

echo "Result: $result"
