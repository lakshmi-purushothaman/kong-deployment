# Getting Started with Promoetheus and Grafana setup for EKS

## Promoetheus Operator

# Kube-prometheus helm chart setup
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

```

# Create Prometheus namespace
```
kubectl create namespace monitoring

```

# Install prometheus
```
helm install prometheus -n monitoring prometheus-community/kube-prometheus-stack \
--set alertmanager.enabled=false \
--set grafana.service.type=LoadBalancer

```

# Check Grafana 
```
echo "export GRAFANA_LB=$(kubectl get service prometheus-grafana -n monitoring \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash

echo $GRAFANA_LB

```

Open the output in the browser

Username is "admin"

and retrieve the password using

```
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

# Data plane metrics to Prometheus

3 components required to capture kong data plane metrics to Prometheus

- Create a global prometheus plugin
- Expose the data plane metrics endpoint as a kubernetes service
- Create the prometheus service monitor

First step is to configure the prometheus plugin provided by kong

## Create a global prometheus plugin

```
kubectl apply -f prometheus-plugin.yaml
```
The next thing to do is to expose the Data Plane metrics port as a new Kubernetes Service. The new Kubernetes Service will be consumed by the Prometheus Service Monitor 

## Expose the data plane metrics endpoint as a kubernetes service

```
kubectl apply -f dp-metrics-service.yaml
```

To test the service, expose the port 8100 using port-forward on another local-terminal

```
kubectl port-forward service/kong-dp-monitoring -n kong-dp 8100

curl localhost:8100/metrics

```

## Create the prometheus service monitor
To create the service monitor collecting metrics from data plane instance; Set the following values in the data plane instance setup helm values

serviceMonitor:
  enabled: true
  namespace: monitoring

which will create the service monitor.

To validate the service monitor created, run

```
kubectl get servicemonitor -n monitoring
```
This should list the "kong-dp-kong" service monitor.

# Check for the data plane metrics in Grafana

In the Grafana dasboard, search for kubernetes/compute resources/ namespace (pods) and watch the kong-dp metrics