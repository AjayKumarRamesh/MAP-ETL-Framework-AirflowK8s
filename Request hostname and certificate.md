# Create Domain name, Request SSL certificate and upload it to kubernetes cluster

### Domain name should be created for exposing services to IBM Intranet

**Request for creation is submitted by Platform team. You can check if it is already created here:**\
https://cwt01.webmaster.ibm.com/dns/records
Search key: map-mktsys

### Request SSL certificate creation for your desired hostname

**Generate CSR file**\
https://csrgenerator.com/

Country **US**\
State **NC**\
Locality **Durham**\
Organization **IBM**\
Organizational Unit **CIO**\
Common Name **airflow.map-mktsys-dev.limited-use.ibm.com**\
Key Size **2048**

**Filenames**\
airflow_map-mktsys-dev_limited-use_ibm_com.csr\
airflow_map-mktsys-dev_limited-use_ibm_com_private.key

**Create profile in IBM Internal Certificate Authority**\
https://daymvs1.pok.ibm.com/ibmca/welcome.do?id=19222

**Request certificate in IBMCAPKI using earlier generated CSR file**

**Download issued certificate**

**Filename**\
cert.pem

**Obtain a copy of IBM intermediate and root certs**\
**Filenames**\
caintermediate.pem\
caroot.pem

**Upload certificate to IBM Cloud**\
https://cloud.ibm.com/resources

**Navigate to: Services - kube-c0hhi59d0s2ho34b3s00 - Your Certificates - Import**

**As a result you get your certificate imported and it gets CRN**

