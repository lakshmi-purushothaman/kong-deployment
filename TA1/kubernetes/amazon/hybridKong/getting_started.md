# Getting Started with EKS

## Amazon CLI

# Run Amazon CLI
```
docker run -it --name "kong-hybrid" --rm -v ${PWD}:/work -w /work --entrypoint /bin/sh amazon/aws-cli:latest

docker exec -it "kong-hybrid"  -v ${PWD}:/work -w /work --entrypoint /bin/sh amazon/aws-cli:latest


cd TA1/kubernetes/amazon/

yum install jq gzip nano tar git openssl
```
## Login to AWS

https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html


- Navigate to "My Security Credentials" section in your profile. 
- Create an access key and make note of accesskey and secret
- Choose a AWS Region to use from the list
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html

```
aws configure

AWS Access Key ID [None]: AWS Access Key
AWS Secret Access Key [None]: AWS Secret
Default region name [None]: eu-west-2
Default output format [None]: json

```

## AWS CLI

- Kubernetes needs a service account to manage Kubernetes cluster 
- In AWS this is an IAM role 
    - Follow "Create your Amazon EKS cluster IAM role" [here](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html) 



## Create role for EKS
```
role_arn=$(aws iam create-role --role-name getting-started-eks-role --assume-role-policy-document file://assume_policy.json | jq .Role.Arn | sed s/\"//g)
aws iam attach-role-policy --role-name getting-started-eks-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-role-policy --role-name getting-started-eks-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

```
### Create the cluster VPC
```
curl https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-05-08/amazon-eks-vpc-sample.yaml -o vpc.yaml
aws cloudformation deploy --template-file vpc.yaml --stack-name kong-ta2-eks
```
## To grab your stack details 
```
aws cloudformation list-stack-resources --stack-name kong-ta2-eks > stack.json
```
### Create EKS cluster
```
aws eks create-cluster \
--name kong-ta2-eks \
--role-arn $role_arn \
--resources-vpc-config subnetIds=subnet-024bd087afebf088f,subnet-05b80b69cf664d9a6,subnet-0f63c65fb5bf182ed,securityGroupIds=sg-09f6d79e609cd8e26,endpointPublicAccess=true,endpointPrivateAccess=false

aws eks list-clusters
aws eks describe-cluster --name kong-ta2-eks
```
## Get a kubeconfig for the cluster

```

aws eks update-kubeconfig --name kong-ta2-eks --region eu-west-2

#grab the config if you want it
cp ~/.kube/config .
```

## Download kubectl

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

```
## Add nodes to our cluster

```

# create our role for nodes
role_arn=$(aws iam create-role --role-name getting-started-eks-role-nodes --assume-role-policy-document file://assume_node_policy.json | jq .Role.Arn | sed s/\"//g)

aws iam attach-role-policy --role-name getting-started-eks-role-nodes --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name getting-started-eks-role-nodes --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-role-policy --role-name getting-started-eks-role-nodes --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
aws iam attach-role-policy --role-name getting-started-eks-role-nodes --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

```
More details on node permissions [here](https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html)


More details on instance types to choose from [here](https://aws.amazon.com/ec2/instance-types/)

```
aws eks create-nodegroup \
--cluster-name kong-ta2-eks \
--nodegroup-name subnet01-nodegroup \
--node-role $role_arn \
--subnets subnet-024bd087afebf088f \
--disk-size 200 \
--scaling-config minSize=1,maxSize=2,desiredSize=1 \
--instance-types t2.small
```

## Assigning EBS service account
```
aws eks describe-cluster \
  --name kong-ta2-eks \
  --query "cluster.identity.oidc.issuer" \
  --output text

  https://oidc.eks.eu-west-2.amazonaws.com/id/23245985CE61DE71B2DBDDAC36E00EAE
```

To get the aws account id

```
aws sts get-caller-identity
```
To create the role

```
aws iam create-role \
  --role-name getting-started-eks-EBS-CSI-DriverRole \
  --assume-role-policy-document file://assume_csi_driver_policy.jsom

aws iam attach-role-policy --role-name getting-started-eks-EBS-CSI-DriverRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

kubectl annotate serviceaccount ebs-csi-controller-sa \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::680765974998:role/getting-started-eks-EBS-CSI-DriverRole

```

## Install Helm

```
curl -LO https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz
tar -C /tmp/ -zxvf helm-v3.4.0-linux-amd64.tar.gz
rm helm-v3.4.0-linux-amd64.tar.gz
mv /tmp/linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

helm version
```

## Cleanup
```
aws eks delete-nodegroup --cluster-name kong-ta2-eks --nodegroup-name subnet01-nodegroup
aws eks delete-cluster --name kong-ta2-eks

aws iam detach-role-policy --role-name getting-started-eks-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam delete-role --role-name getting-started-eks-role

aws iam detach-role-policy --role-name getting-started-eks-role-nodes --policy-arn  arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam detach-role-policy --role-name getting-started-eks-role-nodes --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam detach-role-policy --role-name getting-started-eks-role-nodes --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

aws iam delete-role --role-name getting-started-eks-role-nodes

aws cloudformation delete-stack --stack-name getting-started-eks
```