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











# DB2 Data Management Console LDAP configuration

Best practices for security in IBM Db2 Data Management Console\
https://community.ibm.com/community/user/hybriddatamanagement/blogs/yuan-feng/2021/08/23/best-practices-for-security-in-ibm-db2-data-manage

---
### Login to Data Management Console

https://airflow.map-mktsys-dev.limited-use.ibm.com/dmc/console/ \
Administrator privileges are required

---
### Open “Administration” configuration

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/5_1.jpg">

---
### Open “Settings”

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/5_2.jpg">

---
### Go to “Authentication” tab

Set authentication type to “LDAP”

Connection setting
```
Host name: bluepages.ibm.com
Port: 636
SSL method: LDAPS
Trust store type: PKCS12
Key store type: PKCS12
```
Click Next

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/5_3.jpg">

---
### Authentication method setting

```
Authentication method: Simple
Bind DN: uid=c-tkfu897,c=us,ou=bluepages,o=ibm.com
Bind password:
```

Note: Bind DN is mapfunc@us.ibm.com serial number, password is located in 1Password

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/5_4.jpg">

---
### User and Group setting

```
User base DN: ou=bluepages,o=ibm.com
User login attribute type: mail
Group DN: cn=CIO_Dyna_BAI-000009_PROD,ou=memberlist,ou=ibmgroups,o=ibm.com
Member attribute type: uniquemember
User ID attribute type: dn
```
In this case all members of  CIO_Dyna_BAI-000009_PROD BlueGroup will be Console Administrators. You can add multiple groups by clicking on “plus”.

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/5_5.jpg">

---
### Test user login
```
Test user ID: type your w3id
Test user password: type your w3id password
```
After clicking Test you should receive “Succeed” if everything is configured properly.

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/5_6.jpg">

---
**Save the configuration by clicking “Save”**