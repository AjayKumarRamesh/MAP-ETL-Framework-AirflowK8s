#!/bin/bash

cd /db_backup
timestamp=$(date +%Y%m%d_%H%M%S)
echo "Creating backup at ${timestamp}"
pg_dump --format=c airflow > /db_backup/airflow_bkp.${timestamp}
ls -la /db_backup/airflow_bkp.${timestamp}

echo "Rotating backup files"
echo "Files to be deleted:"
ls -t | awk "NR>${NUM_BACKUPS}"
ls -t | awk "NR>${NUM_BACKUPS}" | xargs rm -f