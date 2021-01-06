echo $CTX_CLUSTER1
echo $CTX_CLUSTER2

sleep 2

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

istioctl install --context="${CTX_CLUSTER1}" -f cluster1.yaml -y &
PID1=$!
istioctl install --context="${CTX_CLUSTER2}" -f cluster2.yaml -y &
PID2=$!
wait $PID1
wait $PID2
istioctl x create-remote-secret \
    --context="${CTX_CLUSTER1}" \
    --name=cluster1 | \
kubectl apply -f - --context="${CTX_CLUSTER2}"
istioctl x create-remote-secret \
    --context="${CTX_CLUSTER2}" \
    --name=cluster2 | \
kubectl apply -f - --context="${CTX_CLUSTER1}"

