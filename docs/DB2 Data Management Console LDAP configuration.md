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

---
### Update LDAP bind password

If mapfunc password expire you won't be able to login to DMC because the authentication against BluePages will not work.
To update LDAP bind password you have to do the following:

Login to IBM Cloud using CLI
```
ibmcloud login --sso
ibmcloud ks cluster config --cluster map-dal10-16x64-01
```

Find the DMC POD in monitoring namespace
```
kubectl get pods -n monitoring | grep db2-dmc
db2-dmc-xxx-xxxx                                      1/1     Running   0          52m
```

Connect to the DMC POD
```
kubectl exec --stdin --tty -n monitoring db2-dmc-xxx-xxxx -- /bin/bash
```

Encrypt the new password (copy the output)
```
/opt/ibm-datasrvrmgr/dsutil/bin/crypt.sh <new_password>
```

You can decrypt the string (if needed)
```
/opt/ibm-datasrvrmgr/dsutil/bin/crypt.sh -d <wtiv2_xxxxxxxx>
```

Edit the DMC LDAP configuration file:
```
vi /mnt/realconfigs/ent/ext_ldap_config_v2.json
```

Replace bind password with the new string:
```
"bind_password" : "wtiv2_xxxxx"
```

Restart the deployment
```
kubectl rollout restart -n monitoring deployment db2-dmc
```

