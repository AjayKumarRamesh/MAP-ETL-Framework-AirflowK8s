### Build

**Here and below I'm using Powershell on my Windows PC here**

**Set local client to use IBM container registry and list namespaces available in IBM Cloud account**\
ibmcloud cr login\
ibmcloud cr namespace-list

**Switch to the folder containing build files**\
d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s \
**Build locally, tag and push images of my services to IBM Cloud container registry**\
docker build -t us.icr.io/map-dev-namespace/airflow -f DockerfileAirflow . \
docker push us.icr.io/map-dev-namespace/airflow:latest

**List images in IBM Cloud registry**\
ibmcloud cr image-list

### Namespace

**Create namespace for Airflow and set CLI to use it**\
kubectl create namespace airflow \
kubectl config set-context --current --namespace=airflow

### Ingress Secret and Deployment

**Create Domain name, Request SSL certificate and upload it to kubernetes cluster**\
**Get certificate CRN to be used in command below**

[Follow these steps](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Ingress%20SSL%20Certificates.md)

**Create Ingress Secret for Airflow namespace**\
\#DEV\# ibmcloud ks ingress secret create --name airflow-internal-domain-cert --cluster map-dal10-16x64-01 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:ae8edb9f-492e-457c-becd-5d16f7ab3232:certificate:47658dbf034e73a57ebe93616172f661 -n airflow \
\#TEST\# ibmcloud ks ingress secret create --name airflow-internal-domain-cert --cluster map-dal10-16x64-02 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:86a29ea8-9702-42ad-969d-62ef26f97c80:certificate:ce76eae470ed8296b7d4a5ac52960521 -n airflow \
\#PROD\# ibmcloud ks ingress secret create --name airflow-internal-domain-cert --cluster map-dal10-16x64-03 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:64c4e116-9d78-4771-b8c5-8c6213d3e65e:certificate:b9c6e4e43b4eab181821e3ed2f98261f -n airflow

**Make sure certificate is added to the cluster**\
\#DEV\# ibmcloud ks ingress secret ls -c map-dal10-16x64-01 \
\#TEST\# ibmcloud ks ingress secret ls -c map-dal10-16x64-02 \
\#PROD\# ibmcloud ks ingress secret ls -c map-dal10-16x64-03

**Deploy Ingresses**\
d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
\#DEV\# kubectl apply -f ingresses_dev.yml -n airflow \
\#TEST\# kubectl apply -f ingresses_test.yml -n airflow \
\#PROD\# kubectl apply -f ingresses_prod.yml -n airflow

### Prepare and Deploy Secrets

**Encrypt data with base 64 before storing it in YAML file**

**To encrypt use !LINUX! command line. Powerhell encoding does not work!**\
echo -n "xxxxxx" | base64

**Deploy secrets to K8s cluster**\
d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
\#DEV\# kubectl apply -f secrets_dev.yml -n airflow \
\#TEST\# kubectl apply -f secrets_test.yml -n airflow \
\#PROD\# kubectl apply -f secrets_prod.yml -n airflow

### Deploy Service

d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f services.yml -n airflow

### Deploy PVCs

d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f pvcs.yml -n airflow

**Check if status is BOUND**\
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE \
airflow-logs    Bound    pvc-0af1a188-2414-4258-a113-c4b66d0a55c1   20Gi       RWX            ibmc-file-gold   2m57s \

### Deployments

**Copy IBM Cloud CR ImagePullSecret to "airflow" namespace**\
$var1 = kubectl get secret all-icr-io -n default -o yaml \
(echo $var1) -replace "default","airflow" | kubectl create -n airflow -f -

**Modify default ServiceAccount for airflow namespace to use ImagePullSecret from above**\
$var2 = kubectl get serviceaccount default -o yaml -n airflow \
$var2 = $var2 + "imagePullSecrets:" + "- name: all-icr-io" \
$var2 | Where-Object {$_ -notlike "*resourceVersion*"} | kubectl replace serviceaccount -n airflow default -f - \
**To see changes** \
kubectl describe serviceaccount default

d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f deployments.yml -n airflow

### Additional Steps

**Request to open firewall rules and enable cluster to resolve DNS names**\
bluepages.ibm.com	9.57.182.78	 9.17.186.253  9.23.210.79   Port number: 636/TCP
