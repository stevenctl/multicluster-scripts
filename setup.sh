#!/usr/bin/env bash

source lib.sh

export CLUSTERS
export CONTEXTS
init $@
prompt

###################################################################################################
########################################## Cert creation ##########################################
###################################################################################################

echo "Creating certs and secrets..."

# 1. Generate certs

mkdir -p certs
pushd certs
make -f $ISTIO/tools/certs/Makefile.selfsigned.mk root-ca
for c in "${CLUSTERS[@]}"; do 
  make -f $ISTIO/tools/certs/Makefile.selfsigned.mk "${c}-cacerts"
done
popd

# 2. Push to clusters
echo "Pushing to clusters..."
for i in "${!CLUSTERS[@]}"; do 
  c="${CLUSTERS["$i"]}"
  ctx="${CONTEXTS["$i"]}"
  echo "  $c:"
  echo "    creating istio-system namespace"
  kubectl --context="${ctx}" create namespace istio-system
  echo "    creating cacerts secret"
  kubectl --context="${ctx}" create secret generic cacerts -n istio-system \
        --from-file="certs/$c/ca-cert.pem" \
        --from-file="certs/$c/ca-key.pem" \
        --from-file="certs/$c/root-cert.pem" \
        --from-file="certs/$c/cert-chain.pem"
done

#################################################################################################
######################################## Main Install ###########################################
#################################################################################################

echo "Installing istio using $HUB/$TAG..."
declare -a PIDS
for i in "${!CLUSTERS[@]}"; do
  c="${CLUSTERS["$i"]}"
  ctx="${CONTEXTS["$i"]}"
  echo "  $c:"
  echo "    installing istio"
  cat <<EOF > "$c.yaml"
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  # revision: rev1
  values:
    global:
      imagePullPolicy: Always
      meshID: mesh1
      multiCluster:
        clusterName: $c 
      network: network1
EOF
  istioctl install --context="${ctx}" -f "$c.yaml" -y --set hub="$HUB" --set tag="$TAG" &
  PIDS+=("$!")
done 
for pid in "${PIDS[@]}"; do
  wait $pid
done

echo "Waiting a bit for clusters to init..."
sleep 5

#################################################################################################
######################################## Remote Secret###########################################
#################################################################################################

echo "Creating remote secrets..."

for ((i = 0 ; i < "${#CONTEXTS[@]}" ; i++)); do
  for ((j = $(($i+1)) ; j < "${#CONTEXTS[@]}" ; j++)); do
    c1="${CLUSTERS["$i"]}"
    ctx1="${CONTEXTS["$i"]}"
    c2="${CLUSTERS["$j"]}"
    ctx2="${CONTEXTS["$j"]}"
    echo "  $c2 -> $c1"
    istioctl x create-remote-secret \
      --context="${ctx1}" \
      --name="${c1}"| \
    kubectl apply -f - --context="${ctx2}"
    echo "  $c1 -> $c2"
    istioctl x create-remote-secret \
      --context="${ctx2}" \
      --name="${c2}" | \
    kubectl apply -f - --context="${ctx1}"
  done
done

echo "Done!"
