
# Signing Docker Images

Code Signing with Jenkins Overview: https://taas.cloud.ibm.com/getting-started/codesigning/codesigning-jenkins-artifactory.md

1. Register MIP team on the CISO Code Signing Service: https://ibm.biz/codesigningservice
 - login with your w3id
 - click on "Register for IBM Code Signing"
 - follow the instructions
 - wait for approval
 - once this is done you will receive an e-mail with subject *"[Code Signing Support Request] Approval"*

**SOS Code signing team**: 716-IBMImageSign1221
**Certificate alias**: IBMCodeSignCert1221

2. Use the CISO Code Signing Service to Generate your PFX File
 - Load the CISO Code Signing Service: https://ibm.biz/codesigningservice
 - If you are not already logged in, click Login with your w3id
 - Hover over Sign Code from the menu and select Sign Code from the dropdown
 - Click the Local Sign button
 - From the Platform dropdown select Dynamic
 - From the Docker Environment dropdown select TaaS / Travis
 - Click Review Parameters
 - Click Generate Install Package
 - Download and keep safe your .pfx file, which gives you access to your HSM (Hardware Security Module) Partition. This is your key to accessing your private key from the HSM, and if it is leaked bad actors could sign code as IBM. Later in the process we will upload the .pfx file to Jenkins as a secret file.

3. Jenkins on Kubernetes (JonK) - Configure Code Signing Pod Template for Kubernetes Namespace
 - Follow the instructions on https://taas.cloud.ibm.com/getting-started/codesigning/codesigning-jenkins-artifactory.md
 - or ask platform team to configure Jenkis
 - Template can be updated in Jenkins -> Manage Jenkins -> Manage nodes and clouds -> Configure Clouds -> POD Templates -> **pod-code-signing-agent**

4. Import the PFX File as a Jenkins 'Secret File' Credential
 - Login to your Jenkins server and click Credentials from the left-hand menu
 - A sub-menu should now have opened beneath Credentials on the left-hand menu. Select System to open Jenkins-wide credentials.
 - Click Global credentials (unrestricted)
 - Click Add Credentials from the left-hand menu and enter the following:
  - Kind: Secret File
  - Scope: Global (Jenkins, nodes, items, all children items, etc)
  - File: Upload the pfx (previously downloaded from the CISO Code Signing Service)
  - ID: signing-pfx-file
  - Description: (leave empty)
 -Secret File can be updated in Jenkins -> Manage Jenkins -> Manage Credentials -> signing-pfx-file

5. Configuring Your Jenkins Pipeline for Signing
 - POC Jenkins pipeline to sign images: https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/MIP-Image-Signing-POC/
 - Based on https://github.ibm.com/TAAS/image-signing-demo

6. Verify images with podman locally
 - get the public key IBMCodeSignCert1221-key.pub 
 - create /etc/pki/containers
 - copy (or move) IBMCodeSignCert1221-key.pub to /etc/pki/containers
 - display trust policy file (/etc/containers/policy.json)
```
podman image trust show --raw
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker": {
	    "registry.access.redhat.com": [
		{
		    "type": "signedBy",
		    "keyType": "GPGKeys",
		    "keyPath": "/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"
		}
	    ],
	    "registry.redhat.io": [
		{
		    "type": "signedBy",
		    "keyType": "GPGKeys",
		    "keyPath": "/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"
		}
	    ]
	},
        "docker-daemon": {
	    "": [
		{
		    "type": "insecureAcceptAnything"
		}
	    ]
	}
    }
}
```
 - Accept only signed images from us.icr.io 
```
sudo podman image trust set --type signedBy --pubkeysfile /etc/pki/containers/IBMCodeSignCert1221-key.pub us.icr.io 
```
 - check trust policy 
```
podman image trust show
default                     accept                                                            
registry.access.redhat.com  signedBy                security@redhat.com, security@redhat.com  https://access.redhat.com/webassets/docker/content/sigstore
registry.redhat.io          signedBy                security@redhat.com, security@redhat.com  https://registry.redhat.io/containers/sigstore
us.icr.io                   signedBy                IBMCodeSignCert1221                       
                            insecureAcceptAnything                 
```

 - try to pull signed and unsigned image
```
ibmcloud login --sso
ibmcloud cr login
```
  - unsigned
```
podman --log-level debug pull us.icr.io/map-dev-namespace/adhocdata_lead_xref:jenkins.build.2
Trying to pull us.icr.io/map-dev-namespace/adhocdata_lead_xref:jenkins.build.2...
Error: Source image rejected: A signature was required, but no signature exists
```
  - signed
```
podman --log-level debug pull us.icr.io/map-dev-namespace/adhocdata_lead_xref:signed
Trying to pull us.icr.io/map-dev-namespace/adhocdata_lead_xref:signed...
Getting image source signatures
Checking if image destination supports signatures
Copying blob 0a3452dbfeb7 done  
```
