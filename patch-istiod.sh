#!/bin/bash
IMAGE=$1
CONTEXT=${2:-}
if [ -z $IMAGE ]; then
  echo "must specify an image"
  exit 1
fi

echo "Patching istio-system/istiod to use image $IMAGE"
JSON="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/image\", \"value\": \"$IMAGE\"}]"
echo 'Patch JSON:'
echo $JSON | jq
kubectl --context=$CONTEXT -n istio-system patch deployment istiod --type json -p="$JSON"

