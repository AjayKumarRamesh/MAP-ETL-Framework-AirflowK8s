# User Roles assignment

**Default user self registration role is set in the following file:**\
**MAP-ETL-Framework-AirflowK8s\airflow_conf\webserver_config.py**

_AUTH_USER_REGISTRATION_ROLE_ = _"Public"_

### Roles assigned in Airflow
| № | Environment |	Dev | Test | Prod |
| --- | --- | --- | --- | --- |
| 1 | bwambur@us.ibm.com | Admin | Admin | Admin |
| 2 | Victor.Shcherbatyuk1@ibm.com | Admin | Admin | Admin |
| 3 | fmozingo@us.ibm.com | Admin | Admin | Admin |
| 4 | alex.almanza@ibm.com | Admin | Admin | Admin |
| 5 | souvik.dutta@ibm.com | Admin | Admin | Admin |
| 6 | bbotev@bg.ibm.com | Admin | Admin | Admin |
| 7 | mitko.dimitrov4@ibm.com | Admin | Admin | Admin |
| | | | | |
| 8 | akumarr2@in.ibm.com | Op | Op | Op |
| 9 | ldavidlp@ibm.com | Op | Op | Op |
| 10 | nagendrac@in.ibm.com | Op | Op | Op |
| | | | | |
| 11 | Pooja.Sunkara@ibm.com | Op | Op | Viewer | 
| 12 | rdamelio@us.ibm.com | Op | Op | Viewer |
| 13 | Kranthi.Mandati@ibm.com | Op | Op | Viewer |
| 14 | VARDHAN.VULIPALA@ibm.com | Op | Op | Viewer |
| 15 | Keerthi.Kiran@ibm.com | Op | Op | Viewer |
| 16 | Mohamed.SOLIMAN@ibm.com | Op | Op | Viewer |
| 17 | saghodas@us.ibm.com | Op | Op | Viewer |
| 18 | Sergei.Malakhovski1@ibm.com | Op | Op | Viewer |
| 19 | david.murray@us.ibm.com | Op | Op | Viewer |
| 20 | Sairaj.Alve@ibm.com | Op | Op | Viewer |
| | Default role | Public | Public | Public |

### To request access to Airflow environments please do the following

**Create Jira ticket. Provide the following information**
- You name and desired environment in ticket name
- Provide business justification in description field specifying which kind of access you need
- Set Epic Link, Assignee and Contributor list according to the screenshot below

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_1.jpg">

**Create sub-task with approval and assign it to Souvik Dutta**

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/2_1.jpg">

**Log in to the desired environment to complete self-registration and appear in Users list**\
You will register to Airflow with Public Role. After that Airflow Administrators will set role for your user according to Jira ticket.\

If you see your name in the table above and do not have access required it means you haven't logged in to environment before and haven't completed self-registration. In such case please reach out to Victor.Shcherbatyuk1@ibm.com to get the situation sorted.