# Getting Started with EKS

## Amazon CLI

# Run Amazon CLI
```
docker run -it --name "kong-hybrid" --rm -v ${PWD}:/work -w /work --entrypoint /bin/sh amazon/aws-cli:latest

docker exec -it "kong-hybrid"  --entrypoint /bin/sh amazon/aws-cli:latest

yum install jq gzip nano tar git openssl unzip
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

# Terraform CLI 

```
# Get Terraform

curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/1.3.0/terraform_1.3.0_linux_amd64.zip

curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/1.4.0-beta2/terraform_1.4.0-beta2_linux_arm64.zip
unzip /tmp/terraform.zip
chmod +x terraform && mv terraform /usr/local/bin/
terraform
```

## Terraform Amazon Kubernetes Provider 

```
cd TA1/kubernetes/amazon/terraform

terraform init

terraform plan
terraform apply

```

aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_id)
