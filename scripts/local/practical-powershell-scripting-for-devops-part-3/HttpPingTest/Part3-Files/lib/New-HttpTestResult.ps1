#!/bin/bash

New_HttpTestResult() {
    url=$1
    name=$2
    MaxRetryNo=${3:-10}  # Default to 10 if not provided
    WaitTimeInSeconds=${4:-1}  # Default to 1 second if not provided

    Method="GET"
    TestCounter=0

    while [ $TestCounter -lt $MaxRetryNo ]; do
        ((TestCounter++))

        start_time=$(date +%s%N)
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        end_time=$(date +%s%N)

        duration=$((($end_time - $start_time) / 1000000))

        if [ "$response" -eq 200 ]; then
            break
        else
            sleep $WaitTimeInSeconds
        fi
    done

    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    result="{\"name\":\"$name\",\"status_code\":\"$response\",\"status_description\":\"\",\"attempt_no\":\"$TestCounter/$MaxRetryNo\",\"responsetime_ms\":\"$duration\",\"timestamp\":\"$timestamp\"}"

    echo "$result"
}

# Example usage:
url="https://example.com"
name="TestName"
result=$(New_HttpTestResult "$url" "$name")

echo "Result: $result"
