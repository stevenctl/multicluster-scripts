#!/usr/bin/env bash

POD="$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
            app=sleep -o jsonpath='{.items[0].metadata.name}')"
echo "1 to 2 (from $POD in $CTX_CLUSTER1)"
for i in $(seq 5); do 
  kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep $POD -- curl -s helloworld.local:5000/hello
done 

POD="$(kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l \
            app=sleep -o jsonpath='{.items[0].metadata.name}')"
echo "2 to 1 (from $POD in $CTX_CLUSTER2)"
for i in $(seq 5); do
  kubectl exec --context="${CTX_CLUSTER2}" -n sample -c sleep $POD -- curl -s helloworld.local:5000/hello
done
