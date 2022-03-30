#!/bin/sh
#
# Usage: sh ./docker-compose-update.sh github_username/github_repository
#

# From: https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
    GITHUB_REPO="$1"
    curl --silent "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

download_release_file() {
    GITHUB_REPO="$1"
    TMP_DIR="$2"
    ZIP_FILE="$TMP_DIR/$3.zip"
    curl -Ls --location --request GET https://api.github.com/repos/$GITHUB_REPO/releases/latest \
        | jq -r ".zipball_url" \
        | wget -qi - -O "$ZIP_FILE" \
        && unzip -q -o "$ZIP_FILE" -d "$TMP_DIR" \
        && cp -R $TMP_DIR/$(unzip -Z -1 $ZIP_FILE | head -1)/* $TMP_DIR \
        && rm -R $TMP_DIR/$(unzip -Z -1 $ZIP_FILE | head -1)/ \
        && rm "$ZIP_FILE"
}

GITHUB_REPOSITORY="$1"
DEPLOYMENT_DIR="$1"
TMP=`cat $DEPLOYMENT_DIR/LATEST_VERSION.txt 2>/dev/null || true`
CURRENT_VERSION="${TMP:-0.0.0}"
LATEST_VERSION=`get_latest_release $GITHUB_REPOSITORY`

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    if [ -e "$DEPLOYMENT_DIR" ]; then
        docker-compose -f $DEPLOYMENT_DIR/docker-compose.yml up -d
    fi
    echo "Docker compose is already running the latest version ($LATEST_VERSION)"
else
    echo "Docker compose is running an old version (current: $CURRENT_VERSION, latest: $LATEST_VERSION)"

    # Download the latest release's files
    TMP_DIR=`mktemp -d -t docker-compose-XXXXXXXXXX`
    download_release_file $GITHUB_REPOSITORY $TMP_DIR $LATEST_VERSION

    # Stop the current deployment
    if [ -e "$DEPLOYMENT_DIR" ]; then
        docker-compose -f $DEPLOYMENT_DIR/docker-compose.yml down
    else
        mkdir -p $DEPLOYMENT_DIR
    fi

    # Delete the current deployment
    rm -rf $DEPLOYMENT_DIR/*
    mv $TMP_DIR/* $DEPLOYMENT_DIR

    # Deploy the application
    docker-compose -f $DEPLOYMENT_DIR/docker-compose.yml up -d

    # Store the latest version and remove temporary files
    echo $LATEST_VERSION > $DEPLOYMENT_DIR/LATEST_VERSION.txt
    echo "Docker compose is now running version ${LATEST_VERSION}"
fi