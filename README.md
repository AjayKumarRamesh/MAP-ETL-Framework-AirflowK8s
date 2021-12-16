# MAP-ETL-Framework-AirflowK8s

Deployment and configuration files for Airflow running on K8s integrated with ETL-Framework

---
### List of Services

 - <img src="https://miro.medium.com/max/1080/1*6jjSw8IqGbsPZp7L_43YyQ.png" height="20"> Airflow 2.1.3
 - <img src="https://i.stack.imgur.com/hRJou.gif" height="20"> Python 3.7
 - <img src="https://upload.wikimedia.org/wikipedia/commons/f/f3/Apache_Spark_logo.svg" height="20"> Spark 3.0.1
 - <img src="https://upload.wikimedia.org/wikipedia/commons/2/29/Postgresql_elephant.svg" height="20"> Postgres 10.15

---
### Environment Diagram Simplified
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/env_diagram_simplified.jpg">

---
### Environment Diagram Detailed
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/env_diagram_detailed.jpg">

---
### Overview and Links

**Airflow K8s Web UI**\
```
DEV https://airflow.map-mktsys-dev.limited-use.ibm.com/airflow/login \
TEST https://airflow.map-mktsys-test.limited-use.ibm.com/airflow/login \
PROD https://airflow.map-mktsys-prod.limited-use.ibm.com/airflow/login
```

**The following GitHub repo is linked to Airflow containers via webhook<->listener pipeline. When a new DAG is committed to GitHub it is loaded to Airflow automatically**\
https://github.ibm.com/CIO-MAP/MAP-ETL-Framework

**There is a branch for each environment. Airflow gets branch name to sync with from K8s Secrets** \
DEV https://github.ibm.com/CIO-MAP/MAP-ETL-Framework/tree/dev \
TEST https://github.ibm.com/CIO-MAP/MAP-ETL-Framework/tree/test \
PROD https://github.ibm.com/CIO-MAP/MAP-ETL-Framework/tree/master

**Direct link to K8s console**\
DEV https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c0hhi59d0s2ho34b3s00/service/#/overview?namespace=default \
TEST https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c262vded0jqq2thfho00/service/#/overview?namespace=default \
PROD https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c2om8okd0oh5q4um8sh0/service/#/overview?namespace=default

**IBM Cloud Container Registry namespaces** \
DEV https://cloud.ibm.com/registry/namespaces/map-dev-namespace?region=us-south \
TEST https://cloud.ibm.com/registry/namespaces/mip-test-namespace?region=us-south \
PROD https://cloud.ibm.com/registry/namespaces/mip-prod-namespace?region=us-south

**Postgres Clous SAAS instance** \
DEV https://cloud.ibm.com/services/databases-for-postgresql/crn%3Av1%3Abluemix%3Apublic%3Adatabases-for-postgresql%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3Ac20870c3-8e4a-476e-8fec-86204e4d9703%3A%3A \
TEST https://cloud.ibm.com/services/databases-for-postgresql/crn%3Av1%3Abluemix%3Apublic%3Adatabases-for-postgresql%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3Aae1df8f9-000d-4170-b441-4ea0bf2acb0e%3A%3A \
PROD https://cloud.ibm.com/services/databases-for-postgresql/crn%3Av1%3Abluemix%3Apublic%3Adatabases-for-postgresql%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3A0d500df2-45d3-4357-b639-bb88fa2b1034%3A%3A

**Secrets Manager instance** \
https://cloud.ibm.com/services/secrets-manager/crn%3Av1%3Abluemix%3Apublic%3Asecrets-manager%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3A711889a9-a7fd-47a7-b66d-12c14acccd69%3A%3A

---
### Support Requests

The request should be represented as JIRA ticket in SMSMKTPLAT project: https://jsw.ibm.com/projects/SMSMKTPLAT/issues/SMSMKTPLAT-177?filter=allopenissues
jackieroehl@ibm.com can assist with JIRA questions and how ticket should be formatted.
When the ticket is created send brief description and link to the ticket to the following Slack channel: https://ibm-cio.slack.com/archives/C01HD9TGMB6

The actual work is done by xuyin@cn.ibm.com or MOHAMEDIH@us.ibm.com
They can be contacted directly via Slack.

---
### Documentation
- [Connect to Cluster](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Connect%20to%20Cluster.md)
- [Build & Deployment Manual](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Build%20%26%20Deployment%20Manual.md)
- [Create Domain name, Request SSL certificate and upload it to kubernetes cluster](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Ingress%20SSL%20Certificates.md)
- [User Roles Assignment](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/User%20Roles%20Assignment.md)
- [How Airflow is integrated into ETL Framework](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/How%20Airflow%20is%20integrated%20into%20ETL%20Framework.md)
- [Deploy DAG to Prod](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Deploy%20DAG%20to%20Prod.md)
- [Integrate Airflow with IBM Cloud Secrets Manager](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Integrate%20Airflow%20with%20IBM%20Cloud%20Secrets%20Manager.md)