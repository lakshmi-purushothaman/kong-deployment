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

Kong Vitals
Install prometheus exporter
