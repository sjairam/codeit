#!/bin/bash
# TODO :  Write README
version=0.1


AWS=$(command -v aws)

CAT=$(command -v cat)

KUBECTL=$(command -v kubectl)

clear

sleep 2

#### AWS
#### Check to make sure the aws cli utility is available
if [ ! -f "${AWS}" ]; then
    echo "ERROR: Unable to locate the AWS CLI binary."
    echo "FIX: Please modify the \${AWS} variable in the program header."
    exit 1
fi

#### CAT
#### Check to make sure the cat utility is available
if [ ! -f "${CAT}" ]; then
    echo "ERROR: Unable to locate the cat binary."
    echo "FIX: Please modify the \${CAT} variable in the program header."
    exit 1
fi

#### KUBECTL
#### Check to make sure the kubectl utility is available
if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: Unable to locate the AWS CLI binary."
    echo "FIX: Please modify the \${KUBECTL} variable in the program header."
    exit 1
fi

applySecret ()
{
    echo " --> Entering KUBECTL"
    kubectl -n cattle-system create secret tls tls-rancher-ingress \
        --cert=tls.crt \
        --key=tls.key \
        --dry-run --save-config -o yaml | kubectl apply -f -
    echo " --> after kubectl ! "
}

applyRollingRestart ()
{
    # Update Rancher with SSL Certificate
    #helm upgrade -i rancher rancher-latest/rancher --namespace cattle-system --version ${rancher_version} --set hostname=${hostname} --set bootstrapPassword="${rancher_password}" --set ingress.tls.source=secret --set replicas=1
    kubectl rollout restart deployment rancher

}


if [ "${1}" != "sand" ] || [ "${1}" != "dev" ] || [ "${1}" != "qa" ] || [ "${1}" != "prod" ];
then 
    echo " "
    echo "  Valid entries are sand,dev, qa, lzp or prod "
else
    echo " --> Extracting ssl certs"
    env_prefix=$1
    echo " --> Env prefix is $env_prefix"
    # Create SSL Certificate Kubernetes Secrets
    aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-cert --query SecretString --output text|tr -d '"' > /tmp/tls.crt
    aws secretsmanager get-secret-value --region us-east-1 --secret-id ${env_prefix}-ssl-key --query SecretString --output text|tr -d '"' > /tmp/tls.key
    sleep 5
    applySecret
    applyRollingRestart
fi



