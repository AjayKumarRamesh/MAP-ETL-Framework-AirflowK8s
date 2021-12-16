# Build & Deployment Manual

### Initial Setup

Initial setup is done by platform team.

- IBM Cloud CR namespaces are created for Dev, Test and Prod
- Postgres Cloud SAAS instances are created for Dev, Test and Prod
- Secrets Manager instance is created and MIP Secrets Group is created
- Dev, Test and Prod kubernetes clusters are provisioned and configured:
  - Network configuration to enable DNS name resolving is applied (Calico, CoreDNS)
  - Private and Public Ingress Controllers are configured
  - Secrets Manager Controllers are installed
  - Spark-Kubernetes-Operator is installed to MIP namespace for Spark applications to work
  - LogDNA, Dynatrace, Crowdstrike and other agents are not vital for Airflow to work but are needed for integration with other services

---
### Build

**Here and below I'm using Powershell on my Windows PC**

Set local client to use IBM container registry and list namespaces available in IBM Cloud account
```
ibmcloud cr login
ibmcloud cr namespace-list
```

Switch to the folder containing build files
```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s
```

Build locally, tag and push images of my services to IBM Cloud container registry
```
docker build -t us.icr.io/map-dev-namespace/airflow -f DockerfileAirflow .
```

Push the image to DEV, Test and Prod CR namespaces following dev->test->prod order
```
#DEV#
docker push us.icr.io/map-dev-namespace/airflow:latest
#TEST#
docker pull us.icr.io/map-dev-namespace/airflow:latest
docker tag us.icr.io/map-dev-namespace/airflow:latest us.icr.io/mip-test-namespace/airflow:latest
docker push us.icr.io/mip-test-namespace/airflow:latest
#PROD#
docker pull us.icr.io/mip-test-namespace/airflow:latest
docker tag us.icr.io/mip-test-namespace/airflow:latest us.icr.io/mip-prod-namespace/airflow:latest
docker push us.icr.io/mip-prod-namespace/airflow:latest
```

List images in IBM Cloud registry
```
ibmcloud cr image-list
```

---
### Namespace

Create namespace for Airflow and set CLI to use it
```
kubectl create namespace airflow
kubectl config set-context --current --namespace=airflow
```

---
### Ingress Secret and Deployment

Create Domain name, Request SSL certificate and upload it to kubernetes cluster\
Get certificate CRN to be used in command below

[Follow these steps](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Ingress%20SSL%20Certificates.md)

Create Ingress Secret for Airflow namespace
```
#DEV# ibmcloud ks ingress secret create --name airflow-internal-domain-cert --cluster map-dal10-16x64-01 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:ae8edb9f-492e-457c-becd-5d16f7ab3232:certificate:47658dbf034e73a57ebe93616172f661 -n airflow
#TEST# ibmcloud ks ingress secret create --name airflow-internal-domain-cert --cluster map-dal10-16x64-02 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:86a29ea8-9702-42ad-969d-62ef26f97c80:certificate:ce76eae470ed8296b7d4a5ac52960521 -n airflow
#PROD# ibmcloud ks ingress secret create --name airflow-internal-domain-cert --cluster map-dal10-16x64-03 --cert-crn crn:v1:bluemix:public:cloudcerts:us-south:a/a2edaeffb1cb4cd3a6aefe5282468938:64c4e116-9d78-4771-b8c5-8c6213d3e65e:certificate:b9c6e4e43b4eab181821e3ed2f98261f -n airflow
```

Make sure certificate is added to the cluster
```
#DEV# ibmcloud ks ingress secret ls -c map-dal10-16x64-01
#TEST# ibmcloud ks ingress secret ls -c map-dal10-16x64-02
#PROD# ibmcloud ks ingress secret ls -c map-dal10-16x64-03
```

Deploy Ingresses
```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML
#DEV# kubectl apply -f ingresses_dev.yml -n airflow
#TEST# kubectl apply -f ingresses_test.yml -n airflow
#PROD# kubectl apply -f ingresses_prod.yml -n airflow
```

---
### Deploy Config Maps
```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML
#DEV# kubectl apply -f .\configmaps_dev.yml -n airflow
#TEST# kubectl apply -f .\configmaps_test.yml -n airflow
#PROD# kubectl apply -f .\configmaps_prod.yml -n airflow
```

---
### Prepare and Deploy Secrets

Export environment variable for IBM Cloud CLI Secrets Manager plugin to work with desired Secrets Manager instance
```
$SECRETS_MANAGER_URL="https://711889a9-a7fd-47a7-b66d-12c14acccd69.us-south.secrets-manager.appdomain.cloud"
```

View your secret group ID to be used with command below
```
ibmcloud secrets-manager secret-groups
...
metadata      	  creation_date              description           id                                     last_update_date           name      type
<Nested Object>   2021-09-28T20:15:46.000Z   All secrets for MIP   e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b   2021-10-05T21:35:50.000Z   MIP       application/vnd.ibm.secrets-manager.secret.group+json
```

Create secret in Secrets Manager instance
  - group: MIP (id=e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b)
  - type: arbitrary
  - data: format is shown in commads below (in IU just put the value of your variable here without name)
  
For PowerShell, use single quotation marks to surround the JSON data structure. Additionally, you must escape each double quotation mark that is inside the JSON structure by using a backslash before each double quotation mark

```
#DEV#
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"DEV_AIRFLOW__CORE__FERNET_KEY\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"DEV_AIRFLOW__CORE__SQL_ALCHEMY_CONN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"postgresql://*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"DEV_GIT_ACCESS_TOKEN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"DEV_LDAP_BIND_PASSWORD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'

#TEST#
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_AIRFLOW__CORE__FERNET_KEY\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_AIRFLOW__CORE__SQL_ALCHEMY_CONN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"postgresql://*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_GIT_ACCESS_TOKEN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_LDAP_BIND_PASSWORD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'

#PROD#
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_AIRFLOW__CORE__FERNET_KEY\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_AIRFLOW__CORE__SQL_ALCHEMY_CONN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"postgresql://*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_GIT_ACCESS_TOKEN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_LDAP_BIND_PASSWORD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'
```

Deploy External Secrets to K8s cluster
```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML
\#DEV\# kubectl apply -f .\external_secrets_dev.yml -n airflow
\#TEST\# kubectl apply -f .\external_secrets_test.yml -n airflow
\#PROD\# kubectl apply -f .\external_secrets_prod.yml -n airflow
```

Check that External Secret resource has status "Success"

Check that K8s secret is created, name and value are correct

---
### Deploy Service
```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML
kubectl apply -f services.yml -n airflow
```

---
### Deploy PVCs
```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML
kubectl apply -f pvcs.yml -n airflow
```

Check if status is BOUND
```
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
airflow-logs    Bound    pvc-0af1a188-2414-4258-a113-c4b66d0a55c1   20Gi       RWX            ibmc-file-gold   2m57s
```

---
### Deployments

Copy IBM Cloud CR ImagePullSecret to "airflow" namespace
```
$var1 = kubectl get secret all-icr-io -n default -o yaml
(echo $var1) -replace "default","airflow" | kubectl create -n airflow -f -
```

Modify default ServiceAccount for airflow namespace to use ImagePullSecret from above
```
$var2 = kubectl get serviceaccount default -o yaml -n airflow
$var2 = $var2 + "imagePullSecrets:" + "- name: all-icr-io"
$var2 | Where-Object {$_ -notlike "*resourceVersion*"} | kubectl replace serviceaccount -n airflow default -f -
```

To see changes
```
kubectl describe serviceaccount default
```

```
d:
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML
#DEV# kubectl apply -f deployments_dev.yml -n airflow
#TEST# kubectl apply -f deployments_test.yml -n airflow
#PROD# kubectl apply -f deployments_prod.yml -n airflow
```

---
### Additional Steps

Request to open firewall rules and enable cluster to resolve DNS names
```
bluepages.ibm.com	9.57.182.78	 9.17.186.253  9.23.210.79   Port number: 636/TCP
```