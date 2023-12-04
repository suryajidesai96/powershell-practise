#!/bin/bash

refsInputArray=("refs/heads/releases/1.0.0"
                "refs/heads/releases/1.a.0"
                "refs/heads/releases/1.2.0.5.6.9"
                "refs/heads/release/1.1.1"
                "refs/heads/releases/1.0.1"
                "refs/heads/releases/2.4.3"
                "refs/heads/main"
                "refs/heads/develop")

# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
semVerRegex='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

for ref in "${refsInputArray[@]}"; do
    IFS='/' read -ra refParts <<< "$ref"

    if [ "${refParts[-2]}" == "releases" ]; then
        if [[ "${refParts[-1]}" =~ $semVerRegex ]]; then
            echo "Reference $ref is in releases folder and has a correct semver format"
        else
            echo "Reference $ref is in releases folder but has an incorrect semver format"
        fi
    else
        echo "Reference $ref is not in releases folder"
    fi
done
