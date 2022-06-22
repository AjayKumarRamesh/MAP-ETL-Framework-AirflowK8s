
# Signing Docker Images

Code Signing with Jenkins Overview: https://taas.cloud.ibm.com/getting-started/codesigning/codesigning-jenkins-artifactory.md

Process overview

![Jenkins code signing](/docs/pics/Jenkins_code_signing.png)

**1. Register MIP team on the CISO Code Signing Service:** https://ibm.biz/codesigningservice
 - login with your w3id
 - click on "Register for IBM Code Signing"
 - follow the instructions
 - wait for approval
 - once this is done you will receive an e-mail with subject *"[Code Signing Support Request] Approval"*

**SOS Code signing team**: 716-IBMImageSign1221

**Certificate alias**: IBMCodeSignCert1221

**2. Use the CISO Code Signing Service to Generate your PFX File**
 - Load the CISO Code Signing Service: https://ibm.biz/codesigningservice
 - If you are not already logged in, click Login with your w3id
 - Hover over Sign Code from the menu and select Sign Code from the dropdown
 - Click the Local Sign button
 - From the Platform dropdown select Dynamic
 - From the Docker Environment dropdown select TaaS / Travis
 - Click Review Parameters
 - Click Generate Install Package
 - Download and keep safe your .pfx file, which gives you access to your HSM (Hardware Security Module) Partition. This is your key to accessing your private key from the HSM, and if it is leaked bad actors could sign code as IBM. Later in the process we will upload the .pfx file to Jenkins as a secret file.

**3. Jenkins on Kubernetes (JonK) - Configure Code Signing Pod Template for Kubernetes Namespace**
 - Follow the instructions on https://taas.cloud.ibm.com/getting-started/codesigning/codesigning-jenkins-artifactory.md
 - or ask platform team to configure Jenkis
 - Template can be updated in Jenkins -> Manage Jenkins -> Manage nodes and clouds -> Configure Clouds -> POD Templates -> **pod-code-signing-agent**

**4. Import the PFX File as a Jenkins 'Secret File' Credential**
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

**5. Configuring Your Jenkins Pipeline for Signing**
 - POC Jenkins pipeline to sign images: https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/job/MIP-Image-Signing-POC/
 - Based on https://github.ibm.com/TAAS/image-signing-demo
 - Sample stage to sign and push image
```
pipeline {
    // default agent 
    agent { label 'taas_image' }
                
    stages {

        // Image signing stage should be executed right after the build image stage
        stage('Sign and push image to IBM Container Registry') {
            // Execute this step on Code Signing Agent
            agent { label 'code-signing-agent' }
            // Set the environment variables
            environment {
                // Certificate alias provided by the IBM Code Signing tool
                CERTIFICATE_ALIAS = 'IBMCodeSignCert1221'
                // Temporary public key file - this file is used to verify images 
                PUBLIC_KEY_FILE = "/tmp/${CERTIFICATE_ALIAS}-key.pub"
                // Imported PFX files
                PFX_FILE = credentials('signing-pfx-file')
                // Credentials to access IBM Container Registry
                IBMCLOUD_CREDS = credentials('ibm-cloud-cr')
                // Image build name - replace <namespace>, <image_build>, <build_tag> accrodingly
                IMAGE_BUILD_TAG="us.icr.io/<namespace>/<image_build>:<build_tag>"
                // Image release name - replace <namespace>, <image_release>, <release_tag> accrodingly
                IMAGE_RELEASE_TAG="us.icr.io/<namespace>/<image_release>:<release_tag>"
            }
            steps {
                echo '\n=== Preparing the Environment for Image Signing ==='
                // Inject the PFX file to the required location
                echo '\nInjecting the PFX file...'
                sh '''
                chmod 644 ${PFX_FILE}
                sudo cp ${PFX_FILE} /etc/ekm
                '''

                // Configure local PGP keys for use in signing
                echo '\nConfigure local PGP keys for use in signing'
                sh '''
                    # Download local 'pointer keys' referencing the actual private and public keys stored in the HSM (Hardware Security Module)
                    sudo ucl pgp-key -n ${CERTIFICATE_ALIAS}
                    # Export our public key to be used for image verification
                    sudo gpg2 --armor --output ${PUBLIC_KEY_FILE} --export ${CERTIFICATE_ALIAS}
                    # View content of the public key file - copy the content and save it locally
                    cat ${PUBLIC_KEY_FILE}
                '''

                // Signing and Publishing the Image
                echo '\n=== Signing and Publishing the Image ==='
                sh '''
                    docker images
                    FINGERPRINT=$(sudo gpg2 --no-tty --batch --fingerprint --with-colons "${CERTIFICATE_ALIAS}" | grep '^fpr' | cut -d : -f 10 | head -n 1)
                    LOCAL_DAEMON=$(echo ${DOCKER_HOST} | sed s/tcp/http/)
                    sudo skopeo copy \
                        --dest-creds iamapikey:${IBMCLOUD_CREDS_PSW} \
                        --remove-signatures \
                        --sign-by ${FINGERPRINT} \
                        --src-daemon-host "${LOCAL_DAEMON}" \
                        docker-daemon:${IMAGE_BUILD_TAG} \
                        docker://${IMAGE_RELEASE_TAG}
                '''
            } //steps
        } //stage
    } //stages
} //pipeline
```

**6. Verify images with podman locally**
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
