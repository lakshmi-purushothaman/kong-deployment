# Setting up kong gateway in hybrid mode

## MTLS SETUP
Kong Gateway provides two modes for handling certificate/key pairs:

- Shared mode (Default) Use the Kong CLI to generate a certificate/key pair, then distribute copies across nodes. The certificate/key pair is shared by both CP and DP nodes.
- PKI mode Provide certificates signed by a central certificate authority (CA). Kong validates both sides by checking if they are from the same CA. This eliminates the risks associated with transporting private keys. 

### Create Certificate/key pair
Using the Shared mode and OpenSSL to issue the pair

```
openssl req -new -x509 -nodes -newkey rsa:2048 \
  -keyout ./cluster.key -out ./cluster.crt \
  -days 1095 -subj "/CN=kong_clustering"
```

### Create namespaces for Control plane and Data plane

```
kubectl create namespace kong
```

```
kubectl create namespace kong-dp
```
### Create a Kubernetes secret with the pair

```
kubectl create secret tls kong-cluster-cert --cert=./cluster.crt --key=./cluster.key -n kong
```

# KONG CONTROL PLANE

## Using Helm Chart

```
helm repo add kong https://charts.konghq.com
helm repo update

```

### Install the Control Plane

```
helm install kong kong/kong -n kong \
--set ingressController.enabled=true \
--set ingressController.installCRDs=false \
--set ingressController.image.repository=kong/kubernetes-ingress-controller \
--set ingressController.image.tag=2.0.1 \
--set image.repository=kong/kong-gateway \
--set image.tag=2.6.0.0-alpine \
--set env.database=postgres \
--set env.role=control_plane \
--set env.cluster_cert=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_cert_key=/etc/secrets/kong-cluster-cert/tls.key \
--set cluster.enabled=true \
--set cluster.tls.enabled=true \
--set cluster.tls.servicePort=8005 \
--set cluster.tls.containerPort=8005 \
--set clustertelemetry.enabled=true \
--set clustertelemetry.tls.enabled=true \
--set clustertelemetry.tls.servicePort=8006 \
--set clustertelemetry.tls.containerPort=8006 \
--set proxy.enabled=true \
--set admin.enabled=true \
--set admin.http.enabled=true \
--set admin.type=LoadBalancer \
--set enterprise.enabled=true \
--set enterprise.portal.enabled=false \
--set enterprise.rbac.enabled=false \
--set enterprise.smtp.enabled=false \
--set manager.enabled=true \
--set manager.type=LoadBalancer \
--set secretVolumes[0]=kong-cluster-cert \
--set postgresql.enabled=true \
--set postgresql.postgresqlUsername=kong \
--set postgresql.postgresqlDatabase=kong \
--set postgresql.postgresqlPassword=kong

```

### Validating the Installation
```
kubectl get all -n kong
```
#### Checking the Admin API
```
echo "export CONTROL_PLANE_LB=$(kubectl get service kong-kong-admin \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n kong)" >> ~/.bashrc
bash

echo $CONTROL_PLANE_LB

curl $CONTROL_PLANE_LB:8001 | jq .version

```

#### Configuring Kong Manager 
```
kubectl patch deployment -n kong kong-kong -p "{\"spec\": { \"template\" : { \"spec\" : {\"containers\":[{\"name\":\"proxy\",\"env\": [{ \"name\" : \"KONG_ADMIN_API_URI\", \"value\": \"$CONTROL_PLANE_LB:8001\" }]}]}}}}"

echo "export KONG_MANAGER=$(kubectl get svc -n kong kong-kong-manager --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash

echo $KONG_MANAGER:8002

```
Use browser to view kong manager

# KONG DATA PLANE

### Create Kubernetes Secret for mTLS

```
kubectl create secret tls kong-cluster-cert --cert=./cluster.crt --key=./cluster.key -n kong-dp
```

### Installing Kong Data Plane
```
helm install kong-dp kong/kong -n kong-dp \
--set ingressController.enabled=false \
--set image.repository=kong/kong-gateway \
--set image.tag=2.6.0.0-alpine \
--set env.database=off \
--set env.role=data_plane \
--set env.cluster_cert=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_cert_key=/etc/secrets/kong-cluster-cert/tls.key \
--set env.lua_ssl_trusted_certificate=/etc/secrets/kong-cluster-cert/tls.crt \
--set env.cluster_control_plane=kong-kong-cluster.kong.svc.cluster.local:8005 \
--set env.cluster_telemetry_endpoint=kong-kong-clustertelemetry.kong.svc.cluster.local:8006 \
--set proxy.enabled=true \
--set proxy.type=LoadBalancer \
--set enterprise.enabled=true \
--set enterprise.portal.enabled=false \
--set enterprise.rbac.enabled=false \
--set enterprise.smtp.enabled=false \
--set manager.enabled=false \
--set portal.enabled=false \
--set portalapi.enabled=false \
--set env.status_listen=0.0.0.0:8100 \
--set secretVolumes[0]=kong-cluster-cert
```

### Validating the Installation
```
kubectl get all -n kong-dp
```
#### Checking the Data plane from Control Plane

```
curl $CONTROL_PLANE_LB:8001/clustering/status

curl -i -X GET $CONTROL_PLANE_LB:8001/clustering/data-planes

```
#### Checking the Data Plane Proxy
```
echo "export DATA_PLANE_LB=$(kubectl get svc -n kong-dp kong-dp-kong-proxy --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')" >> ~/.bashrc
bash

echo $DATA_PLANE_LB

curl $DATA_PLANE_LB

```