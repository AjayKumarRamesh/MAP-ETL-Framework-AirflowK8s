# Connect to cluster

### Request Access to IBM Public Cloud Account

Instruction: https://cio-map-ibm-com.gitbook.io/mip/access/connections/ibm-cloud

---
### How to get to K8s web console

- Log in to IBM Public Cloud with your W3ID
```
https://cloud.ibm.com/
Account: 1808859 - Marketing Systems
```

- Navigate to Kubernetes - Clusters - _select your cluster_
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/1_1.jpg">

- Click on Kubernetes web console
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/1_2.jpg">

---
### How to connect to K8s Cluster via ibmcloud and kubectl CLI

**I'm using Powershell on my Windows PC here** \
**Docker Desktop is forbidden now, so in case you need to use "docker" commands (there are no such in this manual) install docker or podman binaries (LINUX or WSL ONLY!)**

Install IBM Cloud CLI

Login to IBM
```
ibmcloud login --sso
```

Install plugins and list them
```
ibmcloud plugin install container-service
ibmcloud plugin install container-registry
ibmcloud plugin install observe-service
ibmcloud plugin install secrets-manager
ibmcloud plugin list
```

Connect to the cluster
```
ibmcloud login -a cloud.ibm.com -r us-south -g IBM-MAP -sso
```

Set cluster context for local client and view current context to make sure everything is ok
```
#DEV# ibmcloud ks cluster config --cluster c0hhi59d0s2ho34b3s00
#TEST# ibmcloud ks cluster config --cluster c262vded0jqq2thfho00
#PROD# ibmcloud ks cluster config --cluster c2om8okd0oh5q4um8sh0
kubectl config current-context
```

Now you can use K8s IDE (i.e. Lens), just select context that was created in your system