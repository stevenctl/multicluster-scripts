#!/usr/bin/env bash

function init() {
  export CONTEXTS=("$@")
  if [ "${#CONTEXTS[@]}" -eq 0 ]; then
    echo "No contexts specified.. grabbing using 'kubectl config get-contexts -oname'"
    CONTEXTS=(`kubectl config get-contexts -oname | grep -v internal`)
  fi
  
  if [ "${#CONTEXTS[@]}" -eq 0 ]; then
    echo "No contexts.. exiting."
    exit 1
  fi
  
  # Generate nice names for clusters
  export CLUSTERS=()
  for i in $(seq "${#CONTEXTS[@]}"); do
    CLUSTERS+=("cluster-$i")
  done
}

function prompt() {
  echo "Contexts (${#CONTEXTS[@]}): ${CONTEXTS[*]}"
  echo "Clusters (${#CLUSTERS[@]}): ${CLUSTERS[*]}"
  echo "HUB=${HUB} TAG=${TAG}"
  echo "istioctl path=$(which istioctl) version=$(istioctl version --remote=false)"

  echo "Continue? (y/n)"
  read cont
  if [ "$cont" != "y" ]; then
    exit 1
  fi
}
