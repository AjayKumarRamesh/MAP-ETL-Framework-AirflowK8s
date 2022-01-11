# User Roles assignment

Default user self registration role is set in the following file:\
MAP-ETL-Framework-AirflowK8s\airflow_conf\webserver_config.py

_AUTH_USER_REGISTRATION_ROLE_ = _"Public"_

---
### Roles assigned in Airflow
| № | Environment |	Dev | Test | Prod |
| --- | --- | --- | --- | --- |
| 1 | Victor.Shcherbatyuk1@ibm.com | Admin | Admin | Admin |
| 2 | alex.almanza@ibm.com | Admin | Admin | Admin |
| 3 | souvik.dutta@ibm.com | Admin | Admin | Admin |
| 4 | bbotev@bg.ibm.com | Admin | Admin | Admin |
| 5 | mitko.dimitrov4@ibm.com | Admin | Admin | Admin |
| | | | | |
| 6 | akumarr2@in.ibm.com | Op | Op | Op |
| 7 | ldavidlp@ibm.com | Op | Op | Op |
| 8 | campos.c@ibm.com | Op | Op | Op |
| 9 | Aliaksei.Karaliou@ibm.com | Op | Op | Op |
| 10 | nagendrac@in.ibm.com | Op | Op | Op |
| | | | | |
| 11 | Aliaksei.Karatkevich1@ibm.com | Op | Op | Viewer |
| 12 | bwambur@us.ibm.com | Op | Op | Viewer |
| 13 | Pooja.Sunkara@ibm.com | Op | Op | Viewer |
| 14 | Kranthi.Mandati@ibm.com | Op | Op | Viewer |
| 15 | VARDHAN.VULIPALA@ibm.com | Op | Op | Viewer |
| 16 | Keerthi.Kiran@ibm.com | Op | Op | Viewer |
| 17 | Mohamed.SOLIMAN@ibm.com | Op | Op | Viewer |
| 18 | saghodas@us.ibm.com | Op | Op | Viewer |
| 19 | Sergei.Malakhovski1@ibm.com | Op | Op | Viewer |
| 20 | david.murray@us.ibm.com | Op | Op | Viewer |
| 21 | Sairaj.Alve@ibm.com | Op | Op | Viewer |
| 22 | timothy.figgins1@ibm.com | Op | Op | Viewer |
| 23 | Syarhey.Marozau@ibm.com | Op | Op | Viewer |
| 24 | netrcn03@in.ibm.com | Op | Op | Viewer |
| | | | | |
| 25 | Nastassia.Sichkar@ibm.com | Viewer | Viewer | Viewer |
| 26 | Inga.Ostroumova1@ibm.com | Viewer | Viewer | Viewer |
| 27 | Siamion.Kurakou@ibm.com | Viewer | Viewer | Viewer |
| 28 | krishna.k.kumarakalva@ibm.com | Viewer | Viewer | Viewer |
| 29 | grecialo@ibm.com | Viewer | Viewer | Viewer |
| 30 | silvia.yadira.vargas@ibm.com | Viewer | Viewer | Viewer |
| 31 | sbeeramm@in.ibm.com | Viewer | Viewer | Viewer |
| 32 | sbabayan@ibm.com | Viewer | Viewer | Viewer |
| 33 | yubari@ibm.com | Viewer | Viewer | Viewer |
| | | | | |
| | Default role | Public | Public | Public |

---
### To request access to Airflow environments please do the following:

**Create Jira ticket. Provide the following information:**
- You name and desired environment in ticket name
- Provide business justification in description field specifying **which kind of access** you need
- Set Type, Epic Link, Assignee and Contributor list according to the screenshot below

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/3_1.jpg">

**If requesting access to PROD environment create sub-task with approval**
- Set Type and Assignee according to screenshot below

<img src="https://github.ibm.com/CIO-MAP/MAP-ETL-Framework-AirflowK8s/blob/master/docs/pics/3_2.jpg">

**Log in to the desired environment to complete self-registration and appear in Users list**\
You will register to Airflow with Public Role. After that Airflow Administrators will set role for your user according to Jira ticket.

If you see your name in the table above and do not have access required it means you haven't logged in to environment before and haven't completed self-registration. In such case please reach out to Victor.Shcherbatyuk1@ibm.com to get the situation sorted.
