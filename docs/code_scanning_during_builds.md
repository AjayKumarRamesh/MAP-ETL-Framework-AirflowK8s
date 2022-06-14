
# Code scanning during builds

1. Introduction
SonarQube is a tool for measuring code quality, using static analysis to find code smells, bugs, vulnerabilities, and poor test coverage. In SonarQube a quality gate is a set of conditions that must be met in order for a project to be marked as passed. By adding SonarQube analysis into a Jenkins pipeline, we can ensure that if the SonarQube Quality Gate fails then the pipeline won’t continue to further stages such as publish or release. To do this, we can use the SonarQube Scanner plugin for Jenkins.
The interaction between Jenkins and SonarQube:
- A Jenkins pipeline is started
- The SonarQube scanner is run against a code project, and the analysis report is sent to SonarQube server
- SonarQube finishes analysis and checking the project meets the configured Quality Gate
- Jenkins periodically checks for the analysis result (pass or failure)
- the Jenkins pipeline will continue if the analysis result is a pass or optionally otherwise fail

2. Access to SonarQube Enterprise
 - URL: https://sms-sonarqube-intranet.dal1a.cirrus.ibm.com/
 - Contacts: aalfaruk@ibm.com
 - admin access is required to add Quality Gates and projects

3. Create API key to access SonarQube
 - login to SonarQube https://sms-sonarqube-intranet.dal1a.cirrus.ibm.com/
 - Go to My account -> Security -> Generate Tokens -> type a name (eg. MIP Jenkins) -> click Generate
 - copy and securely store the API token

4. Create projects in SonarQube
 - login to SonarQube
 - click on "Create a project"
 - follow the instructions
 - MIP have following projects created:
   - MAP-ETL-Framework
   - MAP-ETL-Framework-AirflowK8s
   - MIP-Dashboard
   - MIP-ETL-Jenkins-Pipeline

5. Import the SonarQube API token in Jenkins
 - login to Jenkins https://txo-sms-mkt-voc-team-fxo-map-isc-jnks-jenkins.swg-devops.com/
 - click Manage Jenkins (from the left-hand menu) -> Manage Credentials 
 - find (global) domain and click on it
 - click Add Credentials on the left
   - Kind: Secret text
   - Scope: Global 
   - Secret: put the generated API token
   - ID: SONAR_TOKEN_ENTERPRISE
   - Description: Sonarqube Enterprise token
 - click OK

6. Install SonarQube Scanner plugin for Jenkins
 - click Manage Jenkins (from the left-hand menu) -> Manage plugins
 - click on Available and search for "SonarQube Scanner for Jenkins"
 - install the plugin and restart Jenkins

7. Configure SonarQube Scanner for Jenkins
 - click Manage Jenkins (from the left-hand menu) -> Configure system
 - find "SonarQube servers"
 - check "Environment variables"
 - under "SonarQube installations" fill
   - Name: SonarQube
   - Server URL: https://sms-sonarqube-intranet.dal1a.cirrus.ibm.com
   - Server authentication token: choose "Sonarqube Enterprise token" from dropdown
 - click Save

8. Configure SonarQube Scanner installations
 - click Manage Jenkins (from the left-hand menu) -> Global Tool Configuration
 - find "SonarQube Scanner" in settings
 - click "SonarQube Scanner Installations..."
 - Fill up the following:
   - name: sonar-scaner
   - check: Install automatically
   - choose from dropdown the latest version
 - this will inject sonar-scanner during builds
 - click Save

9. Configuring Jenkins Pipeline for code scanning
 - Before implementing this in a pipeline choose which SonarQube project is suitable for the code
 - Only four projects in SonarQube are currently available with configured QualityGate see 4.

```
pipeline {
    // default agent 
    agent { label 'taas_image' }

    stages {
        // Code scanning stage should be executed right after source code checkout
        stage("SonarQube Analysis") {
            environment{
                //SonarQube Scanner plugin base home path 
                scannerBaseHome = "${HOME}/scannerBaseHome"
                //SonarQube Scanner plugin home - based on the scanner version
                SCANNER_HOME = "${scannerBaseHome}/sonar-scanner-4.7.0.2747-linux"
                //SonarQube Scanner additional options - we pass the turststore and password required to connect to SonarQube server
                SONAR_SCANNER_OPTS = "-Djavax.net.ssl.trustStore=${HOME}/cacerts -Djavax.net.ssl.trustStorePassword=changeit -Dsonar.issuesReport.html.enable=true"
                //SonarQube server URL
                SONAR_HOST_URL = "https://sms-sonarqube-intranet.dal1a.cirrus.ibm.com/"
                //Java home required to run the sonar-scanner
                JAVA_HOME = "/usr/lib/jvm/java-11-openjdk-amd64"
                PATH = "${JAVA_HOME}/bin/:${PATH}"
                //SonarQube Project Name - replace <sonar_project> from the list of projects eg. MAP-ETL-Framework
                SONAR_PROJECT_NAME="<sonar_project>"
                //SonarQube Project Key - replace <sonar_key> with the project name eg. MAP-ETL-Framework
                SONAR_PROJECT_KEY="<sonar_key>"
                //File or folders than need to be excluded from scans
                SONAR_EXCLUSIONS="**/*.java, **/docs/**"
            }
            steps {
                script {
                    // Prepare truststore
                    withCredentials([file(credentialsId: 'ibm_sonar_enterprise_cert', variable: 'FILE')]){
                        sh ("keytool -importcert -keystore ${HOME}/cacerts -storepass changeit -file $FILE -alias 'ibm_sonar' -noprompt -trustcacerts")
                    }
                    def scannerHome = tool 'sonar-scanner';
                    withSonarQubeEnv('SonarQube'){
                        sh ("${scannerHome}/bin/sonar-scanner -Dsonar.projectName=${SONAR_PROJECT_NAME} -Dsonar.projectKey=${SONAR_PROJECT_KEY} -Dsonar.exclusions=${SONAR_EXCLUSIONS}")
                    }

                    // Quality Gate Check
                    echo "checking the quality Gate"
                    def tries = 0
                    sonarResultStatus = "PENDING"
                    while ((sonarResultStatus == "PENDING" || sonarResultStatus == "IN_PROGRESS") && tries++ < 5) {
                        try {
                            timeout(time: 1, unit: 'MINUTES') {
                                sonarResult = waitForQualityGate abortPipeline: true
                                sonarResultStatus = sonarResult.status
                            }
                        } catch(ex) {
                            echo "caught exception ${ex}"
                        }
                        echo "waitForQualityGate status is ${sonarResultStatus} (tries=${tries})"
                    }
                    if (sonarResultStatus != 'OK') {
                        error "Quality gate failure for SonarQube: ${sonarResultStatus}"
                    }
                } //script
            } //steps
        } //stage
    } //stages
} //pipeline
```
