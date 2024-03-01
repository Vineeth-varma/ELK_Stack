#! /bin/bash

# Here for few replace 'hostname' with 'IP' under grep.
LB=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${HELMRELEASE}"-es-http |  grep 'hostname' | awk '{print $2}' | sed 's/",//g' | sed 's/"//g')


PORT=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${HELMRELEASE}"-es-http | grep '"port":' | awk '{print $2}' | sed s/,//g)

INDEX="${INDICES}"

#Register Repository
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_snapshot/my_hourly_backup" -H "Content-Type: application/json" -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/logs/hourly"
  }
}'

# Hourly backup, starting from 12 AM GMT, incremental, to retain for 1 week
# Set up a snapshot policy Hourly
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_slm/policy/hourly-snapshots" -H "Content-Type: application/json" -d'
{
  "schedule": "0 0 0/1 * * ?",
  "name": "<hourly-snap-{now/d{yyyy.MM.dd|+12:00}}>",
  "repository": "my_hourly_backup",
  "config": {
    "indices": ["'${INDEX}'"]
  },
  "retention": {
    "expire_after": "7d",
    "min_count": 5,
    "max_count": 50
  }
}'

# Daily backup, 12 AM GMT, full backup, to retain for 1 Month
#Register Repository
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_snapshot/my_daily_backup" -H "Content-Type: application/json" -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/logs/daily"
  }
}'

# Set up a snapshot policy Daily
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_slm/policy/daily-snapshots" -H "Content-Type: application/json" -d'
{
  "schedule": "0 0 12 * * ?",
  "name": "<daily-snap-{now/d{yyyy.MM.dd|+12:00}}>",
  "repository": "my_daily_backup",
  "config": {
    "indices": ["'${INDEX}'"]
  },
  "retention": {
    "expire_after": "30d",
    "min_count": 5,
    "max_count": 50
  }
}'

# Monthly backup, 12 AM GMT, full backup, to retain for 12 months.
#Register Repository
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_snapshot/my_weekly_backup" -H "Content-Type: application/json" -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/logs/weekly"
  }
}'

# Set up a snapshot policy Weekly
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_slm/policy/weekly-snapshots" -H "Content-Type: application/json" -d'
{
  "schedule": "0 0 12 ? * 1",
  "name": "<weekly-snap-{now/d{yyyy.MM.dd|+12:00}}>",
  "repository": "my_weekly_backup",
  "config": {
    "indices": ["'${INDEX}'"]
  },
  "retention": {
    "expire_after": "90d",
    "min_count": 5,
    "max_count": 50
  }
}'

# Monthly backup, 12 AM GMT, full backup, to retain for 12 months.
#Register Repository
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_snapshot/my_monthly_backup" -H "Content-Type: application/json" -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/logs/monthly"
  }
}'

# Set up a snapshot policy Monthly
curl -k -u elastic:<password> -X PUT "https://$LB:$PORT/_slm/policy/monthly-snapshots" -H "Content-Type: application/json" -d'
{
  "schedule": "0 0 12 1 * ?",
  "name": "<monthly-snap-{now/d{yyyy.MM.dd|+12:00}}>",
  "repository": "my_monthly_backup",
  "config": {
    "indices": ["'${INDEX}'"]
  },
  "retention": {
    "expire_after": "365d",
    "min_count": 5,
    "max_count": 50
  }
}'
