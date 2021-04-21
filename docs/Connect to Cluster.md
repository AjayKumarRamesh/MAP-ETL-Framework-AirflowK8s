# Connect to cluster

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
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/1_1.jpg">

- **Click on Kubernetes web console**
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/1_2.jpg">

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

**Now you can use K8s IDE (i.e. Lens), just select context that was created in your system**