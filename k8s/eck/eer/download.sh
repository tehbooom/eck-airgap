#!/usr/bin/env bash
export ENDPOINT_VERSION=8.9.1 
wget -P /opt/registry/images/eer/downloads/endpoint/manifest https://artifacts.security.elastic.co/downloads/endpoint/manifest/artifacts-$ENDPOINT_VERSION.zip
unzip -d /opt/registry/images/eer/downloads/endpoint/manifest /opt/registry/images/eer/downloads/endpoint/manifest/artifacts-$ENDPOINT_VERSION.zip
cat /opt/registry/images/eer/downloads/endpoint/manifest/manifest.json | jq -r '.artifacts | to_entries[] | .value.relative_url' | xargs -I@ curl "https://artifacts.security.elastic.co@" --create-dirs -o "/opt/registry/images/eer/.@"