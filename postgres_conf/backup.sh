#!/bin/bash

cd /db_backup
timestamp=$(date +%Y%m%d_%H%M%S)
echo "Creating backup at ${timestamp}"
pg_dump airflow > /db_backup/airflow_bkp.${timestamp}
ls -la /db_backup/airflow_bkp.${timestamp}

echo "Rotating backup files"
echo "Files to be deleted:"
ls -t | awk 'NR>15' 
ls -t | awk 'NR>15' | xargs rm