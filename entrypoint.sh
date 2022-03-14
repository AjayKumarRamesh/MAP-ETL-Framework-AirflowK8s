#!/bin/bash
set -euo pipefail

########################################################################################################################################################
if [ "$1" = 'afp-web' ]; then

	echo "Copy Airflow Metastore Connection String to Airflow conf"
	sed -i "s|changemestring|${AIRFLOW__CORE__SQL_ALCHEMY_CONN}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Airflow Fernet Key to Airflow conf"
	sed -i "s/changemekey/${AIRFLOW__CORE__FERNET_KEY}/" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Base URL to Airflow conf"
	sed -i "s|changemeurl|${BASE_URL}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy StatsD prefix to Airflow conf"
	sed -i "s/changemeprefix/${STATSD_PREFIX}/" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy LDAP Bind Password to webserver_config.py"
	sed -i "s/changeme/${LDAP_BIND_PASSWORD}/" ${AIRFLOW_HOME}/webserver_config.py
	
	echo "Copy DAGs from GIT"
	git clone --single-branch --branch ${BRANCH} https://${GIT_ACCESS_TOKEN}@github.ibm.com/CIO-MAP/MAP-ETL-Framework ${AIRFLOW_GIT}
	#Fix permisssions for Airflow to be able to run DAGs
	chmod -R 755 /opt/airflow/git/dags
	echo "Create symlink to point Airflow to DAGs folder from GIT repo"
	ln -s ${AIRFLOW_GIT}/dags ${AIRFLOW_HOME}
	
	echo "Starting Git webhook listener"
	export FLASK_APP=${AIRFLOW_HOME}/listen_webserver_git.py
	python -m flask run --host=0.0.0.0 &
	
	echo "Airflow DB init"
	airflow db init
  
	echo "Starting webserver"
	airflow webserver &
	  
	tail -f /dev/null
########################################################################################################################################################
elif [ "$1" = 'afp-sched' ]; then
	
	echo "Copy Airflow Metastore Connection String to Airflow conf"
	sed -i "s|changemestring|${AIRFLOW__CORE__SQL_ALCHEMY_CONN}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Airflow Fernet Key to Airflow conf"
	sed -i "s/changemekey/${AIRFLOW__CORE__FERNET_KEY}/" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Base URL to Airflow conf"
	sed -i "s|changemeurl|${BASE_URL}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy StatsD prefix to Airflow conf"
	sed -i "s/changemeprefix/${STATSD_PREFIX}/" ${AIRFLOW_HOME}/airflow.cfg
	
	echo "Copy DAGs from GIT"
	git clone --single-branch --branch ${BRANCH} https://${GIT_ACCESS_TOKEN}@github.ibm.com/CIO-MAP/MAP-ETL-Framework ${AIRFLOW_GIT}
	#Fix permisssions for Airflow to be able to run DAGs
	chmod -R 755 /opt/airflow/git/dags
	echo "Create symlink to point Airflow to DAGs folder from GIT repo"
	ln -s ${AIRFLOW_GIT}/dags ${AIRFLOW_HOME}
	
	echo "Starting Git webhook listener"
	export FLASK_APP=${AIRFLOW_HOME}/listen_scheduler_git.py
	python -m flask run --host=0.0.0.0 &
	
	echo 'Starting supercronic'
	supercronic ${AIRFLOW_HOME}/afpuser &
	
	echo 'Starting scheduler'
	airflow scheduler &
	
	tail -f /dev/null
########################################################################################################################################################
else
  exec "$@"
fi
