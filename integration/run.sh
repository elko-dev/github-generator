#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COLLECTION=$1
STACK=$2
ENV=$3
LOCAL="local"
STAGE="stage"
DEV="dev"
POSTMAN_ENV="github_generator_$ENV.postman_environment.json"

if [ "$ENV" != "$LOCAL" ] && [ "$ENV" != "$STAGE" ] && [ "$ENV" != "$DEV" ]
then
    echo "$ENV is not a valid environment, must be either $LOCAL, $DEV or $STAGE"
    exit 1
else 
    echo "Running $ENV tests"
fi

function run_postman {
    newman run "$SCRIPT_DIR/$COLLECTION" -e "$SCRIPT_DIR/$POSTMAN_ENV"
}

function setup_url {
    ##define variables
    MACOS="Mac"

    NEWURL=`aws cloudformation describe-stacks \
                --stack-name $STACK \
                --query "Stacks[0].[Outputs[? starts_with(OutputKey, 'ServiceEndpoint')]][0][*].{OutputValue:OutputValue}" \
                --output text`

    echo $NEWURL

    ##Check OS
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     machine=Linux;;
        Darwin*)    machine=Mac;;
        CYGWIN*)    machine=Cygwin;;
        MINGW*)     machine=MinGw;;
        *)          machine="UNKNOWN:${unameOut}"
    esac
    if [ "$machine" == "$MACOS" ]
    then
        echo "You are on device with MAC OS, running sed with '' "
        sed  -i '' "s#{{URL}}#$NEWURL#g" "$SCRIPT_DIR/$COLLECTION"
    else
        echo "You are not on a mac, running sed normally"
        sed  -i "s#{{URL}}#$NEWURL#g" "$SCRIPT_DIR/$COLLECTION"
    fi
}
setup_url
run_postman