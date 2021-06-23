# mcsetup

Utils for installing/cleaning Istio multi-cluster installations. 

## setup.sh

Install Istion on each cluster as a primary cluster and connects them all with remote secrets:

```bash
./setup.sh ctx1 ctx2
```

## cleanup.sh

Removes namespaces, CRDs, webhooks, etc.

```bash
./cleanup.sh ctx1 ctx2
```

## verify.sh/deploy-verify.sh

Used to run the helloworld based verification... only works for 2 clusters; needs rewrite to match setup/cleanup.

## patch-istiod.sh

Used to change the image for istiod in each cluster.. needs rewrite
 