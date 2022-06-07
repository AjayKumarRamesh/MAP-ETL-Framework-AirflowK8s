#!/bin/bash
set -euo pipefail

########################################################################################################################################################
if [ "$1" = 'postgres' ]; then

	if [ ! -f ${POSTGRES_HOME}/air_instance.log ]; then
		echo "There's no DB stored, creating a new instance!"
		/usr/lib/postgresql/10/bin/initdb -D ${POSTGRES_HOME}/air_instance
		#Now that instance is created copy postgres settings files before service is started
		cp /tmp/pg_hba.conf ${POSTGRES_HOME}/air_instance/pg_hba.conf
		cp /tmp/postgresql.conf ${POSTGRES_HOME}/air_instance/postgresql.conf
	
		#Start PGSQL
		/usr/lib/postgresql/10/bin/pg_ctl -D ${POSTGRES_HOME}/air_instance -l ${POSTGRES_HOME}/air_instance.log start
		psql -c "create database ${AIRFLOW_DB};"
		psql -c "create user ${AIRFLOW_DB_USER} with encrypted password '${AIRFLOW_DB_PASSWORD}';"
		psql -c "grant all privileges on database ${AIRFLOW_DB} to ${AIRFLOW_DB_USER};"
	else
		echo "DB is present in persistent storage, spinning it up!"		
		#Permissions are messed by persistent storage provider. Fix it otherwise Postgres won't start
		chmod -R 700 ${POSTGRES_HOME}/air_instance
		#Start PGSQL
		/usr/lib/postgresql/10/bin/pg_ctl -D ${POSTGRES_HOME}/air_instance -l ${POSTGRES_HOME}/air_instance.log start
	fi
		
	tail -f /dev/null
########################################################################################################################################################
if [ "$1" = 'afp-web' ]; then

	echo "Copy Airflow Metastore Connection String to Airflow conf"
	sed -i "s|connectionstr|${AIRFLOW__CORE__SQL_ALCHEMY_CONN}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Airflow Fernet Key to Airflow conf"
	sed -i "s/fernetkey/${AIRFLOW__CORE__FERNET_KEY}/" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Base URL to Airflow conf"
	sed -i "s|baseurl|${BASE_URL}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy StatsD prefix to Airflow conf"
	sed -i "s/statsdprefix/${STATSD_PREFIX}/" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy LDAP Bind User to webserver_config.py"
	sed -i "s/ldapbinduser/${LDAP_BIND_USER}/" ${AIRFLOW_HOME}/webserver_config.py
	echo "Copy LDAP Bind Password to webserver_config.py"
	sed -i "s/ldapbindpassword/${LDAP_BIND_PASSWORD}/" ${AIRFLOW_HOME}/webserver_config.py
	
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
	sed -i "s|connectionstr|${AIRFLOW__CORE__SQL_ALCHEMY_CONN}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Airflow Fernet Key to Airflow conf"
	sed -i "s/fernetkey/${AIRFLOW__CORE__FERNET_KEY}/" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy Base URL to Airflow conf"
	sed -i "s|baseurl|${BASE_URL}|" ${AIRFLOW_HOME}/airflow.cfg
	echo "Copy StatsD prefix to Airflow conf"
	sed -i "s/statsdprefix/${STATSD_PREFIX}/" ${AIRFLOW_HOME}/airflow.cfg
	
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
