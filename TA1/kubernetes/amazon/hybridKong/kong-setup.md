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
helm install kong kong/kong -n kong -f hybridKong/kong-hybrid-cp-values.yaml 
```

### Validating the Installation
```
kubectl get all -n kong
```
#### Checking the Admin API
```
echo "export CONTROL_PLANE_LB=$(kubectl get service kong-kong-admin \-\-output=jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n kong)" >> ~/.bashrc
#For test
echo "export CONTROL_PLANE_LB=$(kubectl get svc -n kong | grep admin | awk '{print $3}')" >> ~/.bashrc

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
helm install kong-dp kong/kong -n kong-dp -f hybridKong/kong-hybrid-dp-values.yaml
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

curl -X POST $CONTROL_PLANE_LB:8001/services -F 'name=mock_service' -F 'url=http://mockbin.org'

curl -X POST -H "Content-Type: application/json" \
    -d '{"name": "mock", "hosts": ["localhost"], "paths":["/mock"]}' \
    $CONTROL_PLANE_LB:8001/services/mock_service/routes

curl --proxy $DATA_PLANE_LB:8000 localhost/mock 


aws eks describe-cluster \
 --name kong-ta2-eks \
 --query "cluster.identity.oidc.issuer" \
 --output text

 kubectl annotate serviceaccount ebs-csi-controller-sa \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::680765974998:role/AmazonEKS_EBS_CSI_DriverRole

aws eks  associate-identity-provider-config  --cluster=kong-ta2-eks --region eu-west-2 --approve


echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo
  annotations:
    konghq.com/strip-path: "true"
    kubernetes.io/ingress.class: kong
spec:
  rules:
  - http:
      paths:
      - path: /bar
        pathType: Prefix
        backend:
          service:
            name: echo
            port: 
              number: 80
' | kubectl apply -f -

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=kong-ta2-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=eu-west-2 \
  --set vpcId=vpc-0b50c3a5c0c8718b4

  cat >load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::680765974998:oidc-provider/oidc.eks.eu-west-2.amazonaws.com/id/209D108987CB81917EB2020D51EDBDEB"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.eu-west-2.amazonaws.com/id/209D108987CB81917EB2020D51EDBDEB:aud": "sts.amazonaws.com",
                    "oidc.eks.eu-west-2.amazonaws.com/id/209D108987CB81917EB2020D51EDBDEB:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::680765974998:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole

  cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::680765974998:role/AmazonEKSLoadBalancerControllerRole
EOF