# Build & Deployment Manual

### Initial Setup

Initial setup is done by platform team.

- Dev, Test and Prod kubernetes clusters are provisioned and configured:
  - Network configuration, DNS name resolving rules are applied (Calico, CoreDNS)
  - Private and Public Ingress Controllers are configured
  - Secrets Manager Controllers are installed
  - IBM Cloud Block-storage plugin is installed
  - Spark-Kubernetes-Operator is installed to MIP namespace for Spark applications to work 
  - LogDNA, Crowdstrike and other agents are not vital for Airflow to work but are needed for integration with other services
- Functional W3ID is provisioned and Cloud/Github API Keys are generated to be used by services
- IBM Cloud CR namespaces are created for Dev, Test and Prod
- Secrets Manager instance is created and MIP Secrets Group is created
- Image pull secret for Spark applications is created in MIP namespace

---
### Build

** I'm using Powershell on my Windows PC here **
** Docker Desktop is forbidden now, so in case you need to use "docker" commands (there are no such in this manual) install docker or podman binaries (LINUX or WSL ONLY!) **

Build images for Airflow and Postgres via Jenkins
https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/MIP-Airflow-POC/
https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/MIP-Airflow-PostgreSQL/

Push the image to DEV, Test and Prod CR namespaces
```
#DEV#
The images are pushed to DEV CR by the pipeline automatically

#TEST#
# Airflow
ibmcloud cr image-tag us.icr.io/map-dev-namespace/airflow:<tag> us.icr.io/mip-test-namespace/airflow:<tag>
ibmcloud cr image-tag us.icr.io/mip-test-namespace/airflow:<tag> us.icr.io/mip-test-namespace/airflow:latest
# Postgres
ibmcloud cr image-tag us.icr.io/map-dev-namespace/postgres:<tag> us.icr.io/mip-test-namespace/postgres:<tag>
ibmcloud cr image-tag us.icr.io/mip-test-namespace/postgres:<tag> us.icr.io/mip-test-namespace/postgres:latest

#PROD#
# Airflow
ibmcloud cr image-tag us.icr.io/mip-test-namespace/airflow:<tag> us.icr.io/mip-prod-namespace/airflow:<tag>
ibmcloud cr image-tag us.icr.io/mip-prod-namespace/airflow:<tag> us.icr.io/mip-prod-namespace/airflow:latest
# Postgres
ibmcloud cr image-tag us.icr.io/mip-test-namespace/postgres:<tag> us.icr.io/mip-prod-namespace/postgres:<tag>
ibmcloud cr image-tag us.icr.io/mip-prod-namespace/postgres:<tag> us.icr.io/mip-prod-namespace/postgres:latest
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
$env:SECRETS_MANAGER_URL="https://711889a9-a7fd-47a7-b66d-12c14acccd69.us-south.secrets-manager.appdomain.cloud"
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
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"DEV_POSTGRES_PWD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'

#TEST#
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_AIRFLOW__CORE__FERNET_KEY\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_AIRFLOW__CORE__SQL_ALCHEMY_CONN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"postgresql://*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_GIT_ACCESS_TOKEN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_LDAP_BIND_PASSWORD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"TEST_POSTGRES_PWD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'

#PROD#
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_AIRFLOW__CORE__FERNET_KEY\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_AIRFLOW__CORE__SQL_ALCHEMY_CONN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"postgresql://*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_GIT_ACCESS_TOKEN\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\":\"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_LDAP_BIND_PASSWORD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\"name\":\"PROD_POSTGRES_PWD\",\"secret_group_id\":\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\",\"payload\": \"*********************\"}]'
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

Check that K8s secrets are created, names and values are correct

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