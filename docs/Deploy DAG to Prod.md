# Deploy DAG to Prod

**Here and below I'm using Powershell on my Windows PC here**

---
### Information you need to get started
  
**To start the deployment corresponding ticket has to be created by the dev team**\
**There should be sub task with completed approval**

**You will need the following information to complete the deployment**

**Docker images:**\
*rubytomip:1.0*

**Github commits numbers:**\
*c8c27a989c1ba5a6034c17421451a7329ec67b4f*\
*be32474322886212a0a16b0ed1c8c8fa6bbabb59*
	
<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/4_1.jpg">

---
### Work with image
	
**Login to IBM Cloud**\
ibmcloud login --sso

**Log in to IBM container registry**\
ibmcloud cr login

**Pull the image from Test namespace**\
docker pull us.icr.io/mip-test-namespace/*rubytomip:1.0*\
**Rename it to prepare for Prod namespace**\
docker tag us.icr.io/mip-test-namespace/*rubytomip:1.0* us.icr.io/mip-prod-namespace/*rubytomip:1.0*\
**Push it to Prod namespace**\
docker push us.icr.io/mip-prod-namespace/*rubytomip:1.0*

---
### If you do it for the 1st time - Git preparation steps

**Clone repo to your PC via Github App**

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/4_2.jpg">

**If you don't have Git CLI download it here:** https://git-scm.com/download/win \
**Run Git CMD**

---
### Work with Git

**Via Git CLI**

**Navigate to the folder with Repo cloned**\
d:\
cd Work\UNICA\MAP-ETL-Framework\
git checkout master

**Mark commits from Test branch to be merged into master to be picked up by Prod env**
git cherry-pick *c8c27a989c1ba5a6034c17421451a7329ec67b4f*
git cherry-pick *be32474322886212a0a16b0ed1c8c8fa6bbabb59*

**Open your GitHub desktop and click "Push origin"**
