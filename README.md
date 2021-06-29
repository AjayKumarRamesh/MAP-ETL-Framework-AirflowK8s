# MAP-ETL-Framework-AirflowK8s
Deployment and configuration files for Airflow running on K8s integrated with ETL-Framework

### List of Services

 - <img src="https://miro.medium.com/max/1080/1*6jjSw8IqGbsPZp7L_43YyQ.png" height="20"> Airflow 2.0.0
 - <img src="https://i.stack.imgur.com/hRJou.gif" height="20"> Python 3.7
 - <img src="https://upload.wikimedia.org/wikipedia/commons/f/f3/Apache_Spark_logo.svg" height="20"> Spark 3.0.1
 - <img src="https://upload.wikimedia.org/wikipedia/commons/2/29/Postgresql_elephant.svg" height="20"> Postgres 10.15

### Environment Diagram Simplified
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/env_diagram_simplified.jpg">

### Environment Diagram Detailed
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/env_diagram_detailed.jpg">

### Overview and Links

**Airflow K8s DEV Web UI**\
https://airflow.map-mktsys-dev.limited-use.ibm.com/airflow/login/\
**Airflow K8s TEST Web UI**\
https://airflow.map-mktsys-test.limited-use.ibm.com/airflow/login/\
**Airflow K8s PROD Web UI**\
https://airflow.map-mktsys-prod.limited-use.ibm.com/airflow/login/

**The following GitHub repo is linked to Airflow containers via webhook<->listener pipeline. When a new DAG is committed to GitHub it is loaded to Airflow automatically**\
https://github.ibm.com/CIO-MAP/MAP-ETL-Framework\
**There is a branch for each environment. Airflow gets branch name to sync with from K8s Secrets**
- "dev" for dev
- "test" for test
- "master" for prod

**Direct link to K8s console**\
https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c0hhi59d0s2ho34b3s00/service/#/overview?namespace=default
https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c262vded0jqq2thfho00/service/#/overview?namespace=default
https://us-south.containers.cloud.ibm.com/kubeproxy/clusters/c2om8okd0oh5q4um8sh0/service/#/overview?namespace=default

### Support Requests

The request should be represented as JIRA ticket in SMSMKTPLAT project: https://jsw.ibm.com/projects/SMSMKTPLAT/issues/SMSMKTPLAT-177?filter=allopenissues
jackieroehl@ibm.com can assist with JIRA questions and how ticket should be formatted.
When the ticket is created send brief description and link to the ticket to the following Slack channel: https://ibm-cio.slack.com/archives/C01HD9TGMB6

The actual work is done by xuyin@cn.ibm.com or MOHAMEDIH@us.ibm.com
They can be contacted directly via Slack.

### Documentation
- [Connect to Cluster](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Connect%20to%20Cluster.md)
- [Build & Deployment Manual](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/Build%20%26%20Deployment%20Manual.md)
- [User Roles Assignment](https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/User%20Roles%20Assignment.md)