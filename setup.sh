echo $CTX_CLUSTER1
echo $CTX_CLUSTER2

sleep 2

if [ -d certs ]; then
  echo "using already created certs/ directory"
else
  mkdir -p certs
  pushd certs
  make -f $ISTIO/tools/certs/Makefile.selfsigned.mk root-ca
  make -f $ISTIO/tools/certs/Makefile.selfsigned.mk cluster1-cacerts
  make -f $ISTIO/tools/certs/Makefile.selfsigned.mk cluster2-cacerts
  popd
fi

kubectl --context="${CTX_CLUSTER1}" create namespace istio-system
kubectl --context="${CTX_CLUSTER1}" create secret generic cacerts -n istio-system \
      --from-file=certs/cluster1/ca-cert.pem \
      --from-file=certs/cluster1/ca-key.pem \
      --from-file=certs/cluster1/root-cert.pem \
      --from-file=certs/cluster1/cert-chain.pem


kubectl --context="${CTX_CLUSTER2}" create namespace istio-system
kubectl --context="${CTX_CLUSTER2}" create secret generic cacerts -n istio-system \
      --from-file=certs/cluster2/ca-cert.pem \
      --from-file=certs/cluster2/ca-key.pem \
      --from-file=certs/cluster2/root-cert.pem \
      --from-file=certs/cluster2/cert-chain.pem

istioctl install --manifests=$ISTIO/manifests --context="${CTX_CLUSTER1}" -f cluster1.yaml -y --set hub="$HUB" --set tag="$TAG" &
PID1=$!
istioctl install --manifests=$ISTIO/manifests --context="${CTX_CLUSTER2}" -f cluster2.yaml -y --set hub="$HUB" --set tag="$TAG" &
PID2=$!
wait $PID1
wait $PID2

echo "wait a bit for cert injection... press any key to create cross-cluster secrets"
read -n 1

istioctl x create-remote-secret \
    --context="${CTX_CLUSTER1}" \
    --name=cluster1 | \
kubectl apply -f - --context="${CTX_CLUSTER2}"
istioctl x create-remote-secret \
    --context="${CTX_CLUSTER2}" \
    --name=cluster2 | \
kubectl apply -f - --context="${CTX_CLUSTER1}"

