echo "1 to 2"
for i in $(seq 5); do 
kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
        app=sleep -o jsonpath='{.items[0].metadata.name}')" \
	    -- curl -s helloworld.sample:5000/hello
done 

echo "2 to 1"
for i in $(seq 5); do 
kubectl exec --context="${CTX_CLUSTER2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l \
        app=sleep -o jsonpath='{.items[0].metadata.name}')" \
	    -- curl -s helloworld.sample:5000/hello
done
