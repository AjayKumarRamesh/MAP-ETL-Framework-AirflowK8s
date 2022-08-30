# MAP ETL Framework Airflow

Deployment and configuration files for Airflow running on K8s integrated with ETL-Framework

### Environment Diagram Simplified
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/env_diagram_simplified.jpg">

### Environment Diagram Detailed
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/MIP_Environment_Diagram_Detailed.drawio.png">

### Overview and Links

**Airflow K8s Web UI**\
DEV https://airflow.map-mktsys-dev.limited-use.ibm.com/airflow/login \
TEST https://airflow.map-mktsys-test.limited-use.ibm.com/airflow/login \
PROD https://airflow.map-mktsys-prod.limited-use.ibm.com/airflow/login

**The following GitHub repo is linked to Airflow containers via webhook<->listener pipeline. When a new DAG is committed to GitHub it is loaded to Airflow automatically**\
https://github.ibm.com/CIO-MAP/MAP-ETL-Framework

**There is a branch for each environment to sync with** \
DEV https://github.ibm.com/CIO-MAP/MAP-ETL-Framework/tree/dev \
TEST https://github.ibm.com/CIO-MAP/MAP-ETL-Framework/tree/test \
PROD https://github.ibm.com/CIO-MAP/MAP-ETL-Framework/tree/master

**Direct link to K8s console**\
DEV https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c0hhi59d0s2ho34b3s00/service/#/overview?namespace=default \
TEST https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c262vded0jqq2thfho00/service/#/overview?namespace=default \
PROD https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c2om8okd0oh5q4um8sh0/service/#/overview?namespace=default

**Docker Images are built via Jenkins TAAS pipelines** \
https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/MIP-Airflow-POC/ \
https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/MIP-Airflow-PostgreSQL/

**IBM Cloud Container Registry namespaces** \
DEV https://cloud.ibm.com/registry/namespaces/map-dev-namespace?region=us-south \
TEST https://cloud.ibm.com/registry/namespaces/mip-test-namespace?region=us-south \
PROD https://cloud.ibm.com/registry/namespaces/mip-prod-namespace?region=us-south

**Postgres Cloud SAAS instance** \
DEV https://cloud.ibm.com/services/databases-for-postgresql/crn%3Av1%3Abluemix%3Apublic%3Adatabases-for-postgresql%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3Ac20870c3-8e4a-476e-8fec-86204e4d9703%3A%3A \
TEST https://cloud.ibm.com/services/databases-for-postgresql/crn%3Av1%3Abluemix%3Apublic%3Adatabases-for-postgresql%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3Aae1df8f9-000d-4170-b441-4ea0bf2acb0e%3A%3A \
PROD https://cloud.ibm.com/services/databases-for-postgresql/crn%3Av1%3Abluemix%3Apublic%3Adatabases-for-postgresql%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3A0d500df2-45d3-4357-b639-bb88fa2b1034%3A%3A

**Secrets Manager instance** \
https://cloud.ibm.com/services/secrets-manager/crn%3Av1%3Abluemix%3Apublic%3Asecrets-manager%3Aus-south%3Aa%2Fa2edaeffb1cb4cd3a6aefe5282468938%3A711889a9-a7fd-47a7-b66d-12c14acccd69%3A%3A

### MAP-ETL-Framework-Airflow Documentation
- [Connect to Cluster](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Connect%20to%20Cluster.md)
- [Build & Deployment Manual](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Build%20%26%20Deployment%20Manual.md)
- [Create Domain name, Request SSL certificate and upload it to kubernetes cluster](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Ingress%20SSL%20Certificates.md)
- [User Roles Assignment](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/User%20Roles%20Assignment.md)
- [How Airflow is integrated into ETL Framework](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/How%20Airflow%20is%20integrated%20into%20ETL%20Framework.md)
- [Integrate Airflow with IBM Cloud Secrets Manager](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Integrate%20Airflow%20with%20IBM%20Cloud%20Secrets%20Manager.md)

---
# Monitoring with Grafana/Prometheus stack

Grafana is single point where all metrics for K8s clusters, Airflow and Custom DB parameters can be viewed.

### Monitoring system architecture diagram

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/MIP-Monitoring-Grafana.drawio.png">

### Overview and Links

**Grafana Web UI** \
https://airflow.map-mktsys-dev.limited-use.ibm.com/grafana/?orgId=1

**DB2 Data Management Console offers in-depth monitoring and control of MIP DB2 instances for DBA team** \
https://airflow.map-mktsys-dev.limited-use.ibm.com/dmc/console/

### Monitoring documentation

- [Monitoring stack deployment](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Monitoring%20Stack%20Deployment.md)
- [DB2 Data Management Console LDAP configuration](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/DB2%20Data%20Management%20Console%20LDAP%20configuration.md)
- [DB2 Data Management Console Email configuration](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/DB2%20Data%20Management%20Console%20Email%20configuration.md)
- [DB2 Data Management Console Repository configuration](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/DB2%20Data%20Management%20Console%20Repository%20configuration.md)
- [Add Airflow Test and Prod environments to monitorung stack](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Add%20Airflow%20Test%20and%20Prod%20to%20Grafana%26Prometheus.md)

---
### Support Requests

Support requests should be addressed to Platform Team.

The request should be represented as JIRA ticket in MITAPLAT project: https://jsw.ibm.com/browse/MITAPLAT \
When the ticket is created send brief description and link to the ticket to the following Slack channel: https://ibm-cio.slack.com/archives/C01HD9TGMB6