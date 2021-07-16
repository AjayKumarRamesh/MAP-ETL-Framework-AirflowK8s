# How Airflow is integrated into ETL Framework

### Environment Diagram Detailed
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/diagrams/env_diagram_detailed.jpg">

### Integration Explained

- **ETL logic is represented as Scala code and compiled as JAR file.**\
_There is Docker image based on JDK image containing specifically compiled Spark libraries and ETL Framework itself (distributed as JAR file as well) provided by ETL Framework team._
- **JAR with ETL code is included to this Docker image file along with supplementary libraries, drivers and DB connectors (developers run "docker build" using Dockerfile where they put path to libraries needed).**
- **This image (new image for each ETL job) is pushed to IBM Container registry.**\
_There is Kubernetes YAML deployment file (provided by ETL Framework team). It describes deployment of GCP Spark Operator Pod which runs Spark-submit command._\
_Spark Operator uses Docker image containing ETL code and ETL Framework as a template to spawn Spark Driver and Executor Pods which perform actual work._
- **YAML is edited by development team to include link to Docker image built beforehand, set job name, set K8s secrets (passwords for sources, etc).**
- **YAML deployment to K8s cluster ( "kubectl apply xxx.yaml" ) is wrapped up into Python code as Airflow DAG.**

As we can see Airflow is integrated with ETL framework, working with it side by side.\
Airflow role here is to schedule DAGs, automate code deployment, collect Job run statistics, logs, etc.\
It is the single centre of managing ETL jobs allowing to control who and how can access triggering jobs, see its logs.