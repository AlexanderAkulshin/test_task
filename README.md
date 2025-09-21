# Internal Service (Helm + GitOps-friendly)

## Usage Scenario

1. **Build the Docker image** of the service and load it into the local kind cluster.  
2. **Deploy the service** to Kubernetes using Helm (dev or prod environment).  
3. **Access the service** via `kubectl port-forward` and check its endpoints (`/readyz`, `/healthz`, JSON env).  
4. (Optional) **Enable autoscaling (HPA)** with metrics-server.  
5. (Optional) **Simulate GitOps workflow**: render Helm → apply through Kustomize.  

## Build
```
docker build -t ghcr.io/alexanderakulshin/internal-service:0.1.0 .
```

## Run in kind
```
kind create cluster --name isvc 
```

```
kind load docker-image ghcr.io/alexanderakulshin/internal-service:0.1.0 --name isvc
```

## Install (dev)
```
helm upgrade --install isvc-dev charts/internal-service  `
  -n isvc-dev --create-namespace `
  --set hub=ghcr.io/alexanderakulshin,image=internal-service,tag=0.1.0,prod=false"
```

## Install (prod)
```
helm upgrade --install isvc-prod charts/internal-service `
  -n isvc-prod --create-namespace `
  --set hub=ghcr.io/alexanderakulshin,image=internal-service,tag=0.1.0,prod=true
```

## Access
```
kubectl -n isvc-dev port-forward svc/isvc-dev-internal-service 8080:8080
```
### Bash
```
curl localhost:8080 | jq
```
### PowerShell
```
Invoke-WebRequest http://127.0.0.1:8080/readyz
```
```
Invoke-WebRequest http://127.0.0.1:8080/healthyz
```
```
$EnvVars = Invoke-WebRequest http://127.0.0.1:8080
$EnvVars.Content
```


## HPA metrics
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## GitOps (render)
```
helm template isvc-dev charts/internal-service `
  -n isvc-dev `
  --set hub=ghcr.io/alexanderakulshin,image=internal-service,tag=0.1.0,prod=false `
  --output-dir gitops/base
```

```
kustomize build gitops/overlays/dev | kubectl apply -f -
```
