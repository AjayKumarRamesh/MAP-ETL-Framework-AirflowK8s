# query-exporter build, run and deploy

**query-exporter** is a Prometheus exporter which allows collecting metrics from database queries, at specified time intervals.

Project link:\
https://pypi.org/project/query-exporter/

Docker HUB:\
https://hub.docker.com/r/adonato/query-exporter

Grafana Labs software is allowed for IBM internal use\
https://w3.ibm.com/w3publisher/supplier-security-risk-management/critical-software/systems-management

### Build and deploy query-exporter using Jenkins

Jenkins pipeline script is available here: [queryexporter.jenkinsfile](/queryexporter.jenkinsfile)

Jenkins job is available here: [Monitoring-query-exporter](https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/Monitoring-query-exporter/)

You need to login to Jenkins and run the job which will build and push the image to IBM Container registry and then will update its configuration if there are any changes.

Current configuration file can be found here: [config.yaml](monitoring/config.yaml)

**Rest of the descriptions below are just for information**

---

### Run query-exporter locally

To run query-exporter locally for experiments you can do the following

Pull query-exporter image from Docker HUB
```
docker pull adonato/query-exporter
```

Create configuration file
You can use the [config.yaml](monitoring/config.yaml) or create one based on the query-exporter documentation.

Run the image
```
docker run --name query-exporter -p 9560:9560/tcp -v config.yaml:/config.yaml:Z --rm -it adonato/query-exporter:latest
```

Access the output (metrics) on\
http://localhost:9560/metrics

### Build query-exporter image locally

Debug messages are disabled by default and if we want to enable them we have to build the query-exporter image

Checkout the repository
```
git init
git clone https://github.com/albertodonato/query-exporter.git
```

Modify the Dockerfile to enable debug messages
```
sed -i \'s/"-H", "0.0.0.0"/"-L", "DEBUG", "-H", "0.0.0.0"/g\' Dockerfile
```
This will replace the last line of Dockerfile to 
```
ENTRYPOINT ["query-exporter", "/config.yaml", "-L", "DEBUG", "-H", "0.0.0.0"]
```

Build the image
```
docker build -t localhost/query-exporter:debug -f Dockerfile .
```

Run the image
```
docker run --name query-exporter -p 9560:9560/tcp -v config.yaml:/config.yaml:Z --rm -it adonato/query-exporter:latest
```

Access the output (metrics) on\
http://localhost:9560/metrics

### Build query-exporter image and push it to IBM Container Registry

The process is similar to building the image locally

Checkout the repository
```
git init
git clone https://github.com/albertodonato/query-exporter.git
```

Modify the Dockerfile to enable debug messages
```
sed -i \'s/"-H", "0.0.0.0"/"-L", "DEBUG", "-H", "0.0.0.0"/g\' Dockerfile
```
This will replace the last line of Dockerfile to 
```
ENTRYPOINT ["query-exporter", "/config.yaml", "-L", "DEBUG", "-H", "0.0.0.0"]
```

Login to IBM Container registry
```
ibmcloud login --sso
ibmcloud cr login
```

Build the image
```
docker build -t us.icr.io/map-dev-namespace/query-exporter:debug -f Dockerfile .
```

Push the image to IBM 
```
docker push us.icr.io/map-dev-namespace/query-exporter:debug
```


