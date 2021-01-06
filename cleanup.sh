echo $CTX_CLUSTER1
echo $CTX_CLUSTER2

sleep 2

kubectl --context="${CTX_CLUSTER1}" delete namespace istio-system &
kubectl --context="${CTX_CLUSTER2}" delete namespace istio-system &
kubectl --context="${CTX_CLUSTER1}" delete namespace sample &
kubectl --context="${CTX_CLUSTER2}" delete namespace sample &
