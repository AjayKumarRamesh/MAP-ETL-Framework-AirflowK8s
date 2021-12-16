# Integrate Airflow with IBM Cloud Secrets Manager

**Here and below I'm using Powershell on my Windows PC**

**As an example I'm providing ticket numbers, ID names, variable names from our Dev environment. Please change accordingly when working with Secrets Manager for your own purposes**

---
### Useful links to get common understanding

**Secrets Manager IBM documentation. This tutorial explains the whole process end to end from creating secret to installing External Secret Controller**\
https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-tutorial-kubernetes-secrets

**External Secret k8s resource documentation**\
https://github.com/external-secrets/kubernetes-external-secrets

**Example how different YAMLs are written depending on secret type (user/password, arbitrary)**\
https://github.com/No9/kubernetes-external-secrets-sample

---
### Prerequisites

**Make sure you have access to Secrets Manager instance in IBM cloud to create and delete secrets in MIP group**

**Create a ticket for Platform Team to set up External Secrets Controllers**\
https://jsw.ibm.com/browse/SMSMKTPLAT-1065

---
### Set up Secrets Manager CLI

**Install IBM Cloud Secrets Manager plugin**\
ibmcloud login --apikey \*\*\*\*\*\*\*\*\*\*\*\*\
ibmcloud plugin install secrets-manager\
$SECRETS_MANAGER_URL="https://711889a9-a7fd-47a7-b66d-12c14acccd69.us-south.secrets-manager.appdomain.cloud"

**If you copy your service endpoint URL from the Secrets Manager UI, be sure to trim /api from the URL.**\
**Nick hasn't trimmed /api from external secrets controller deployment config so it didn't work.**\
**Change deployment secrets-manager-tutorial-kubernetes-external-secrets and restart external secrets controller**\
IBM_CLOUD_SECRETS_MANAGER_API_ENDPOINT: https://711889a9-a7fd-47a7-b66d-12c14acccd69.us-south.secrets-manager.appdomain.cloud

**View your secret group ID to be used with command below**\
ibmcloud secrets-manager secret-groups\
PS D:\Work\UNICA\MAP-ETL-Framework-AirflowK8s\YML> ibmcloud secrets-manager secret-groups\
...\
metadata          creation_date              description           id                                     last_update_date           name   type\
<Nested Object>   2021-09-28T20:15:46.000Z   All secrets for MIP   e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b   2021-10-05T21:35:50.000Z   MIP    application/vnd.ibm.secrets-manager.secret.group+json

---
### Work with Secrets

**Use original Secret "airflow-connection-strings" that we have to retrieve environment variable values and names**

**Create secret in Secrets Manager instance**\
    **- group: MIP (id=e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b)**\
    **- type: arbitrary**\
    **- data: format is shown in commads below (in IU just put the value of your variable here without name)**\
**For PowerShell, use single quotation marks to surround the JSON data structure. Additionally, you must escape each double quotation mark that is inside the JSON structure by using a backslash before each double quotation mark**

ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\\"name\\":\\"DEV_AIRFLOW__CORE__FERNET_KEY\\",\\"secret_group_id\\":\\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\\",\\"payload\\":\\"\*\*\*\*\*\*\*\*\*\*\*\*\\"}]'\
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\\"name\\":\\"DEV_AIRFLOW__CORE__SQL_ALCHEMY_CONN\\",\\"secret_group_id\\":\\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\\",\\"payload\":\\"\*\*\*\*\*\*\*\*\*\*\*\*\\"}]'\
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\\"name\\":\\"DEV_GIT_ACCESS_TOKEN\\",\\"secret_group_id\\":\\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\\",\\"payload\\":\\"\*\*\*\*\*\*\*\*\*\*\*\*\\"}]'\
ibmcloud secrets-manager secret-create --secret-type arbitrary --resources '[{\\"name\\":\\"DEV_LDAP_BIND_PASSWORD\\",\\"secret_group_id\\":\\"e5d844cd-fc4f-6b2c-3dd0-5f393e5ae76b\\",\\"payload\\": \\"\*\*\*\*\*\*\*\*\*\*\*\*\\"}]'

**Create external secret yaml .\external_secrets_dev.yml**

```
apiVersion: 'kubernetes-client.io/v1'
kind: ExternalSecret
metadata:
  name: <name of the external secret resource which is created>
  namespace: airflow
spec:
  backendType: ibmcloudSecretsManager
  keyByName: true #this option allows to select secret by name not by UID#
  data:
    - key: <name of the secret in secrets manager instance>
      property: payload
      name: <name of environment variable which will be exposed to pod>
      secretType: arbitrary
```

**Deploy external secret yaml**\
d:\
cd \work\unica\MAP-ETL-Framework-AirflowK8s\YML\
kubectl apply -f .\external_secrets_dev.yml -n airflow

**Check that External Secret resource has status "Success"**

**Check that K8s secret is created, name and value are correct**

**Add the following both to Webserver and Scheduler sections**
**Edit deployments_dev.yml**\

```
spec:
  template:
    spec:
      containers:
        envFrom:
        - secretRef:
            name: airflow-core-fernet-key
        - secretRef:
            name: airflow-core-sql-alchemy-conn
        - secretRef:
            name: git-access-token
        - secretRef:
            name: ldap-bind-password
```

---
### Finalizing steps

**Restart Airflow**

**To change secret value you have to delete it from secrets manager and create a new one with the same name**\
ibmcloud secrets-manager secret-delete --secret-type SECRET-TYPE --id ID [--force]\
**Since External Secret resource searches for secrets by name, the new one will be picked up and the value of K8s secret will be replaced**
**You'll only have to restart Airflow**

**Delete "airflow-connection-strings" k8s secret**