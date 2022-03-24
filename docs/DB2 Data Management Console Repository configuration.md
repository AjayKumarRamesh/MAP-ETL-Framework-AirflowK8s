# DB2 Data Management Console Repository configuration

---
### Login to IBM Cloud and open DB2 console

https://cloud.ibm.com/resources

---
### Download DigiCertGlobalRootCA.crt

Go to: Administration > Connections > click on Download SSL Certificate \
Save DigiCertGlobalRootCA.crt locally

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/7_1.jpg">

---
### Copy DigiCertGlobalRootCA.crt to the container

Using IBM Cloud CLI login to the cloud and configure the cluster \
```
ibmcloud login --sso
ibmcloud ks cluster config --cluster map-dal10-16x64-01
```

List the PODs in monitoring namespace \
```
kubectl get pods -n monitoring
```

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/7_2.jpg">

Find the one db2-dmc and copy the DigiCertGlobalRootCA.crt
```
kubectl cp DigiCertGlobalRootCA.crt  monitoring/db2-dmc-xxxx-xxxx:/mnt/realconfigs/ent/
```

---
### Create a Trust store

Connect to the db2-dmc container \
```
kubectl exec --stdin --tty -n monitoring db2-dmc--xxxx-xxxx -- /bin/bash
```

Create the trust store trust.p12
```
cd /mnt/realconfigs/ent/
/opt/ibm-datasrvrmgr/java/jre/bin/keytool -import -file DigiCertGlobalRootCA.crt -alias "DigiCert Global Root CA" -storetype PKCS12 -keystore trust.p12
```

Type a password twice when it is requested (eg. changeit) and remember it

Check if trust.p12 is created successful
```
/opt/ibm-datasrvrmgr/java/jre/bin/keytool  -list -v -storetype PKCS12 -keystore trust.p12
```

---
### Login to Data Management Console

https://airflow.map-mktsys-dev.limited-use.ibm.com/dmc/console/ \
Administrator privileges are required

---
### Update Repository configuration

Go to: Administration > Settings > Repository
```
Connection type: IBM Db2
Host: dc400977-47fc-4300-a596-e57eccef27d3.bv7c3o6d0vfhru3npds0.databases.appdomain.cloud
Port: 30140
Database: BLUDB
Repository schema: IBMCONSOLE1
Use SSL: check
Truststore location: /mnt/realconfigs/ent/trust.p12
Truststore password: the one created in step 4 (eg. changeit)
Username: mapfunc
Password: from 1Password
```

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/7_3.jpg">

---

### Monitor the log files for errors

There are couple important log files in db2-dm container that can be monitored
```
tail -f  /mnt/logs/DS_System.0
tail -f  /mnt/logs/repoUtil.0 
```

The same information is available in LogDNA