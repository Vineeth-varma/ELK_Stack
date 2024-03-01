# Deploying Elastic Operator on Kubernetes

**1. Adding Repository**
```
helm repo add elastic https://helm.elastic.co
```

**2. Updating Repository**
```
helm repo update
```

**3. Cluster-wide Global Installation**
```
helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace    # Risky Sometimes
```

**4. Restricted Installation, It avoids installing any cluster-scoped resources and restricts the operator to manage only a set of pre-defined namespaces.**
```
helm install elastic-operator-crds elastic/eck-operator-crds                             # Installing CRD's
helm install elastic-operator elastic/eck-operator -n vineeth --set=installCRDs=false    # Installing Operator 
```
