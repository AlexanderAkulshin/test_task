# Internal Service (Helm + GitOps-friendly)

## Prereqs
- Docker, kind, kubectl, Helm v3, (опц.) kustomize
- Интернет (для загрузки образов и metrics-server)

## Build
docker build -t ghcr.io/alexanderakulshin/internal-service:0.1.0 .

## Run in kind
<pre> ```kind create cluster --name isvc ``` </pre>
kind load docker-image ghcr.io/alexanderakulshin/internal-service:0.1.0 --name isvc

## Install (dev)
helm upgrade --install isvc-dev charts/internal-service  `
  -n isvc-dev --create-namespace `
  --set hub=ghcr.io/alexanderakulshin,image=internal-service,tag=0.1.0,prod=false"

## Install (prod)
helm upgrade --install isvc-prod charts/internal-service `
  -n isvc-prod --create-namespace `
  --set hub=ghcr.io/alexanderakulshin,image=internal-service,tag=0.1.0,prod=true

## Access
kubectl -n isvc-dev port-forward svc/isvc-dev-internal-service 8080:8080
curl localhost:8080 | jq

## HPA metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

## GitOps (render)
helm template isvc-dev charts/internal-service `
  -n isvc-dev `
  --set hub=ghcr.io/alexanderakulshin,image=internal-service,tag=0.1.0,prod=false `
  --output-dir gitops/base

kustomize build gitops/overlays/dev | kubectl apply -f -
