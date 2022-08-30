# K8s Image pull secret which is used by DAGs to connect to IBM CR

Update or create default-us-icr-io Image pull secret for mip namespace to use mapfunc IBM Cloud API Key \
It is used by DAGs to pull images from IBM CR and secret name "default-us-icr-io" is hardcoded in spark jobs configuration

- Open Kubernetes Dashboard
- Select "map" namespace
- Click on Secrets (on the left)
- Find default-us-icr-io
- Edit and replace
  - "password" with the new API Token
  - "auth" with the output from 
```
echo "iamapikey:************" | base64
# without the last 4 symbols "Cg=="
# In our case 
"auth": ************

# The whole line with result
{"auths":{"us.icr.io":{"username":"iamapikey","password":"************","email":"iamapikey","auth":"************"}}}
```