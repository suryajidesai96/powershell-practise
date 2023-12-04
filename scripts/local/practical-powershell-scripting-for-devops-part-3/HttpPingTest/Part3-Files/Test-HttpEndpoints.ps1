#!/bin/bash

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -TestsFilePath)
        TestsFilePath="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        # unknown option
        shift
        ;;
    esac
done

# Set default value if TestsFilePath is not provided
TestsFilePath=${TestsFilePath:-"./Tests.json"}

# Create a Stopwatch Object
start_time=$(date +%s.%N)

# Convert JSON Config Files String value to a JSON object
TestsObj=$(jq '.' "$TestsFilePath")

# Import the Tester Function
source ./lib/New-HttpTestResult.sh

# Define the New-HttpTestResult function
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

# Define the function code
funcDef=$(declare -f New_HttpTestResult)

# Execute parallel jobs
results=$(echo "$TestsObj" | parallel --jobs 50 --halt now,fail=1 "eval \"$funcDef\"; New_HttpTestResult {}")

echo "$results" | column -t

# Stop the Stopwatch
end_time=$(date +%s.%N)

# Calculate the elapsed time
elapsed_time=$(echo "$end_time - $start_time" | bc)

echo "Total Script Execution Time: $elapsed_time Seconds"
