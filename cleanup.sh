echo $CTX_CLUSTER1
echo $CTX_CLUSTER2
echo $CTX_CLUSTER3

sleep 2

declare -a PIDS

for ctx in "${CTX_CLUSTER1}" "${CTX_CLUSTER2}" "${CTX_CLUSTER3}"; do
  echo "cleaning $ctx"
  kubectl --context="${ctx}" delete namespace istio-system &
  PIDS+=($!)
  kubectl --context="${ctx}" delete namespace sample &
  PIDS+=($!)
  kubectl --context="${ctx}" delete validatingwebhookconfigurations istiod-istio-system &
  PIDS+=($!)
  kubectl --context="${ctx}" delete mutatingwebhookconfigurations istio-sidecar-injector &
  PIDS+=($!)
  kubectl --context="${ctx}" delete clusterrole istiod-istio-system &
  PIDS+=($!)
  kubectl --context="${ctx}" delete clusterrolebinding istiod-istio-system &
  PIDS+=($!)
  kubectl --context="${ctx}" delete clusterrole istio-reader-istio-system &
  PIDS+=($!)
  kubectl --context="${ctx}" delete clusterrolebinding istio-reader-istio-system &
  PIDS+=($!)
done

for pid in "${PIDS[@]}"; do
  wait $pid
done

