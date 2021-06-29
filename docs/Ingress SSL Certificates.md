# Create Domain name, Request SSL certificate and upload it to kubernetes cluster

**I've used Test env as an example**

### Domain name should be created for exposing services to IBM Intranet

**Request for creation is submitted by Platform team. You can check if it is already created here:**\
https://cwt01.webmaster.ibm.com/dns/records
Search key: map-mktsys

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_1.jpg">

### Request SSL certificate creation for your desired hostname

**Generate CSR file**\
https://csrgenerator.com/

Country **US**\
State **NC**\
Locality **Durham**\
Organization **IBM**\
Organizational Unit **CIO**\
Common Name **airflow.map-mktsys-test.limited-use.ibm.com**\
Key Size **2048**

**Filenames**
- airflow_map-mktsys-test_limited-use_ibm_com.csr
- airflow_map-mktsys-test_limited-use_ibm_com_private.key

**Create profile in IBM Internal Certificate Authority**\
https://daymvs1.pok.ibm.com/ibmca/certificateProfiles.do?lang=en

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_2.jpg">
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_3.jpg">
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_4.jpg">

**Request certificate in IBMCAPKI using earlier generated CSR file**

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_5.jpg">
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_6.jpg">

**Download issued certificate in PKCS7b format**

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_7.jpg">

**Convert certificate to PEM format before uploading it to cloud**

**Upload certificate to IBM Cloud**\
https://cloud.ibm.com/resources

**Navigate to: Services - kube-certmgr-c262vded0jqq2thfho00 - Your Certificates - Import**

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_8.jpg">
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_9.jpg">

**As a result you get your certificate imported and it gets CRN. Save it somewhere to be used later**

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_10.jpg">

