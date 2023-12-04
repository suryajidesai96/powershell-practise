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

# Convert JSON Config Files String value to a JSON object
TestsObj=$(jq '.' "$TestsFilePath")

# Import the Tester Function
source ./lib/New-HttpTestResult.sh
