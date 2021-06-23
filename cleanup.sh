#!/usr/bin/env bash

source lib.sh
export CLUSTERS
export CONTEXTS
init $@
prompt

declare -a PIDS

for ctx in "${CONTEXTS[@]}"; do
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
  kubectl --context="${ctx}" get crd | grep istio | xargs -n1 kubectl --context="${ctx}" delete crd &
  PIDS+=($!)
done

for pid in "${PIDS[@]}"; do
  wait $pid
done
