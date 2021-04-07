# MAP-ETL-Framework-AirflowK8s
Deployment and configuration files for Airflow running on K8s integrated with ETL-Framework

### List of Services

 - <img src="https://miro.medium.com/max/1080/1*6jjSw8IqGbsPZp7L_43YyQ.png" height="20"> Airflow 2.0.0
 - <img src="https://i.stack.imgur.com/hRJou.gif" height="20"> Python 3.7
 - <img src="https://www.computing.co.uk/w-images/cc6f36ae-ffb1-4271-8847-725556046f5c/0/apachesparklogo-580x358.png" height="20"> Spark 3.0.1
 - <img src="https://upload.wikimedia.org/wikipedia/commons/2/29/Postgresql_elephant.svg" height="20"> Postgres 10.15

### Environment Diagram Simplified
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/env_diagram_simplified.jpg">

### Environment Diagram Detailed
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/env_diagram_detailed.jpg">

### Overview and Links

**Airflow K8s POC Web UI**\
https://map-dal10-16x64-01-3e85c10138e3d9eb765a34cf4d1f9197-0000.us-south.containers.appdomain.cloud/airflow/home

**The following GitHub repo is linked to Airflow containers via webhook<->listener pipeline. When a new DAG is committed to GitHub it is loaded to Airflow automatically**\
https://github.ibm.com/CIO-MAP/MAP-ETL-Framework

**Direct link to K8s console**\
https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c0hhi59d0s2ho34b3s00/service/#/overview?namespace=default

### Request Access to IBM Public Cloud Account

**Instruction:** https://w3.ibm.com/w3publisher/cio-marketing-systems/marketing-platform/reference-documents/481a8660-7ad6-11eb-ab1a-bbcf8f30fb44 \
**AccessHub link:** https://ibm.idaccesshub.com/ECMv6/request/requestHome

**Application:** Marketing Systems Cloud account \
**Groups:** MAP Admin, MAP Non Prod и MAP Prod \
**Justification:** I'm a MAP team member responsible for Kubernetes cluster administration and development

### How to get to K8s web console

- **Log in to IBM Public Cloud with your W3ID**\
https://cloud.ibm.com/ \
Account: 1808859 - Marketing Systems

- **Navigate to Kubernetes - Clusters - _map-dal10-16x64-01_**
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/1.jpg">
- **Click on Kubernetes web console**
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/2.jpg">

### How to connect to K8s Cluster via ibmcloud and kubectl CLI

**Here and below I'm using Powershell on my Windows PC here**

**Login to IBM**\
ibmcloud login --sso

**Install plugins and list them**\
ibmcloud plugin install container-service \
ibmcloud plugin install container-registry \
ibmcloud plugin install observe-service \
ibmcloud plugin list

**Install Docker Desktop**

**Connect to the cluster**\
ibmcloud login -a cloud.ibm.com -r us-south -g IBM-MAP -sso \
**Set cluster context for local client and view current context to make sure everything is ok**\
ibmcloud ks cluster config --cluster c0hhi59d0s2ho34b3s00 \
kubectl config current-context

**Set local client to use IBM container registry and list namespaces available in IBM Cloud account**\
ibmcloud cr login\
ibmcloud cr namespace-list

### Build

**Switch to the folder containing build files**\
d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s \
**Build locally, tag and push images of my services to IBM Cloud container registry**\
docker build -t us.icr.io/map-dev-namespace/postgres -f DockerfilePostgres . \
docker push us.icr.io/map-dev-namespace/postgres:latest \
docker build -t us.icr.io/map-dev-namespace/airflow -f DockerfileAirflow . \
docker push us.icr.io/map-dev-namespace/airflow:latest

**List images in IBM Cloud registry**\
ibmcloud cr image-list

### Namespace

**Create namespace for Airflow and set CLI to use it**\
kubectl create namespace airflow \
kubectl config set-context --current --namespace=airflow

### Prepare and Deploy Secrets

**Encrypt data with base 64 before storing it in YAML file**

**To encrypt use !LINUX! command line. Powerhell encoding does not work!**\
echo -n "xxxxxx" | base64

**Deploy secrets to K8s cluster**\
d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f secrets.yml -n airflow

### Deploy Service

d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f services.yml -n airflow

### Ingress Secret and Deployment

**View Ingress Sercret name for default namespace**\
ibmcloud ks cluster get --cluster map-dal10-16x64-01 \
Ingress Subdomain:              map-dal10-16x64-01-3e85c10138e3d9eb765a34cf4d1f9197-0000.us-south.containers.appdomain.cloud \
Ingress Secret:                 map-dal10-16x64-01-3e85c10138e3d9eb765a34cf4d1f9197-0000

**Get CRN for default Ingress Secret**\
PS C:\Users\shcherbatyuk> ibmcloud ks ingress secret get -c map-dal10-16x64-01 --name map-dal10-16x64-01-3e85c10138e3d9eb765a34cf4d1f9197-0000 --namespace default\
OK \
Name:           map-dal10-16x64-01-3e85c10138e3d9eb765a34cf4d1f9197-0000 \
Namespace:      default \
CRN:            crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:ae8edb9f-492e-457c-becd-5d16f7ab3232:certificate:6b319c12eff2ba3c32dbc44507a9feec \
Expires On:     2021-05-10T22:23:50+0000 \
Domain:         map-dal10-16x64-01-3e85c10138e3d9eb765a34cf4d1f9197-0000.us-south.containers.appdomain.cloud \
Status:         created \
User Managed:   false \
Persisted:      true

**Create Ingress Secret for Airflow namespace**\
ibmcloud ks ingress secret create --cluster map-dal10-16x64-01 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:ae8edb9f-492e-457c-becd-5d16f7ab3232:certificate:6b319c12eff2ba3c32dbc44507a9feec --name ingress-airflow-tls --namespace airflow

**Deploy Ingresses**\
d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f ingresses.yml -n airflow

### Deploy PVCs

d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f pvcs.yml -n airflow

**Check if status is BOUND**\
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE \
airflow-logs    Bound    pvc-0af1a188-2414-4258-a113-c4b66d0a55c1   20Gi       RWX            ibmc-file-gold   2m57s \
postgres-data   Bound    pvc-baf25360-65cd-4238-a228-0570c757fb8a   20Gi       RWO            ibmc-file-gold   2m57s

### Deployments

**Copy IBM Cloud CR ImagePullSecret to "airflow" namespace**\
$var1 = kubectl get secret all-icr-io -n default -o yaml \
(echo $var1) -replace "default","airflow" | kubectl create -n airflow -f -

**Modify default ServiceAccount for airflow namespace to use ImagePullSecret from above**\
$var2 = kubectl get serviceaccount default -o yaml \
$var2 = $var2 + "imagePullSecrets:" + "- name: all-icr-io" \
$var2 | Where-Object {$_ -notlike "*resourceVersion*"} | kubectl replace serviceaccount default -f - \
**To see changes** \
kubectl describe serviceaccount default

d: \
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML \
kubectl apply -f deployments.yml -n airflow

### Support Requests

The request should be represented as JIRA ticket in SMSMKTPLAT project. \
https://jsw.ibm.com/projects/SMSMKTPLAT/issues/SMSMKTPLAT-177?filter=allopenissues \
jackieroehl@ibm.com can assist with JIRA questions and how ticket should be formatted.

The actual work is done by xuyin@cn.ibm.com or MOHAMEDIH@us.ibm.com

**Request to open firewall rules and enable cluster to resolve DNS names**\
bluepages.ibm.com	9.57.182.78	 9.17.186.253  9.23.210.79   Port number: 636/TCP