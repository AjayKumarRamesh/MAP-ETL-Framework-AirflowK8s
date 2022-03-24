# DB2 Data Management Console LDAP configuration

### Login to Data Management Console

https://airflow.map-mktsys-dev.limited-use.ibm.com/dmc/console/ \
Administrator privileges are required

---
### Open “Administration” configuration

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/6_1.jpg">

---
### Open “Settings”

---
### Go to “Email” tab

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/6_2.jpg">

---
### Enter the settings for the email server

```
Host name: smtp.sendgrid.net
Server port: 587
Email address for sender: mapfunc@us.ibm.com
Use TLS: check
Requires Authentication: check
Authentication user name: apikey
Authentication password: take the API key from 1Password
```

Note: Information about the mail server and authentication was provided by the Platform team.

---
**Save the configuration by clicking “Save”**