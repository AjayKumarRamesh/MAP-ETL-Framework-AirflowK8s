# Add Airflow Test and Prod to Grafana&Prometheus

### Preparations

Login to cloud
```
ibmcloud login --apikey ************
```

Login to cluster
```
#TEST# ibmcloud ks cluster config --cluster c262vded0jqq2thfho00
#PROD# ibmcloud ks cluster config --cluster c2om8okd0oh5q4um8sh0
```

Create namespace for monitoring
```
kubectl create namespace monitoring
```

---
### StatsD Exporter Deployment

Installing statsd-exporter with Helm\
I'm using setting serviceMonitor.enabled=false to install statsd-exporter without installing prometheus stack, otherwise you'll get error "no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
```
helm install statsd-exporter --set image.tag=latest --set serviceMonitor.enabled=false --set-file statsd.mappingConfig=monitoring/statsd_mapping.yml hahow/prometheus-statsd-exporter -n monitoring
```

Expose statsd-exporter to be accessible from Prometheus in DEV cluster
```
#TEST# kubectl apply -f monitoring/statsd_exporter_proxied_test.yml
#PROD# kubectl apply -f monitoring/statsd_exporter_proxied_prod.yml
```

Edit private LoadBalancer Service in kube-system namespace
```
#TEST# private-crc262vded0jqq2thfho00-alb1
#PROD# private-crc2om8okd0oh5q4um8sh0-alb1
spec:
  ports:
    - name: proxied-tcp-9102
      protocol: TCP
      port: 9102
      targetPort: 9102
```

Final external link
```
#TEST# 10.221.175.106:9102
#PROD# 10.38.78.139:9102
```

Restart ALB
```
#TEST# ibmcloud ks ingress alb update -c c262vded0jqq2thfho00
#PROD# ibmcloud ks ingress alb update -c c2om8okd0oh5q4um8sh0
```

Add the exposed endpoint to prometheus scrape config in DEV cluster

Reinstall prometheus-stack with the new config in DEV
```
ibmcloud ks cluster config --cluster c0hhi59d0s2ho34b3s00
helm uninstall prometheus-stack -n monitoring
helm install prometheus-stack -f monitoring/prometheus-stack-conf.yml prometheus-community/kube-prometheus-stack -n monitoring
```

---
### Calico Configuration

Disable calico policy blocking traffic flow from intranet to clusters (do for all 3 clusters)\
Make sure the policy is not redeployed with some automation\
In case network flow stopped contact MOHAMEDIH@us.ibm.com

```
calicoctl delete GlobalNetworkPolicy block-private
```

---
### Airflow Configuration

```
#TEST# ibmcloud ks cluster config --cluster c262vded0jqq2thfho00
#PROD# ibmcloud ks cluster config --cluster c2om8okd0oh5q4um8sh0
```

Update Airflow ConfigMap with StatsD prefix
```
#TEST# kubectl apply -f YML/configmaps_test.yml -n airflow
#PROD# kubectl apply -f YML/configmaps_prod.yml -n airflow
```

Update image
```
#TEST#
docker pull us.icr.io/map-dev-namespace/airflow:latest
docker tag us.icr.io/map-dev-namespace/airflow:latest us.icr.io/mip-test-namespace/airflow:latest
docker push us.icr.io/mip-test-namespace/airflow:latest
#PROD#
docker pull us.icr.io/mip-test-namespace/airflow:latest
docker tag us.icr.io/mip-test-namespace/airflow:latest us.icr.io/mip-prod-namespace/airflow:latest
docker push us.icr.io/mip-prod-namespace/airflow:latest
```

Restart airflow deployments
```
kubectl rollout restart deployment/airflow-webserver -n airflow
kubectl rollout restart deployment/airflow-scheduler -n airflow
```