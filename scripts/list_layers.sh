#!/bin/bash

# Lists most recent layers ARNs across regions to STDOUT
# Optionals args: [layer-name] [region]

LAYER_NAMES=("Datadog-Python27" "Datadog-Python36" "Datadog-Python37")
AVAILABLE_REGIONS=(us-east-2 us-east-1 us-west-1 us-west-2 ap-south-1 ap-northeast-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 ca-central-1 eu-central-1 eu-west-1 eu-west-2 eu-west-3 sa-east-1)

# Check region arg
if [ -z "$2" ]; then
    >&2 echo "Region parameter not specified, running for all available regions."
    REGIONS=("${AVAILABLE_REGIONS[@]}")
else
    >&2 echo "Region parameter specified: $2"
    if [[ ! " ${AVAILABLE_REGIONS[@]} " =~ " ${2} " ]]; then
        >&2 echo "Could not find $2 in available regions: ${AVAILABLE_REGIONS[@]}"
        >&2 echo ""
        >&2 echo "EXITING SCRIPT."
        return 1
    fi
    REGIONS=($2)
fi

# Check region arg
if [ -z "$1" ]; then
    >&2 echo "Layer parameter not specified, running for all layers "
    LAYERS=("${LAYER_NAMES[@]}")
else
    >&2 echo "Layer parameter specified: $1"
    if [[ ! " ${LAYER_NAMES[@]} " =~ " ${1} " ]]; then
        >&2 echo "Could not find $1 in layers: ${LAYER_NAMES[@]}"
        >&2 echo ""
        >&2 echo "EXITING SCRIPT."
        return 1
    fi
    LAYERS=($1)
fi

for region in "${REGIONS[@]}"
do
    for layer_name in "${LAYERS[@]}"
    do
        last_layer_arn=$(aws lambda list-layer-versions --layer-name $layer_name --region $region | jq -r ".LayerVersions | .[0] |  .LayerVersionArn")
        if [ -z $last_layer_arn ]; then
             >&2 echo "No layer found for $region, $layer_name"
        else
            echo $last_layer_arn
        fi
    done
done