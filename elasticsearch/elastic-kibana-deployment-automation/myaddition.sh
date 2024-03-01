#! /bin/bash

sudo echo "elastic ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers


sudo echo "export PATH=$PATH"| sudo tee -a /home/elastic/.bashrc
source /home/elastic/.bashrc

LB=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${HELMRELEASE}"-es-http |  grep "hostname" | awk '{print $2}' | sed 's/",//g' | sed 's/"//g')


PORT=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${HELMRELEASE}"-es-http | grep '"port":' | awk '{print $2}' | sed s/,//g)

############### This is to get the elasticsearch password from secrets and elasticsearch cluster health so that we can enable backup script ###################
while  [ ! -f /tmp/flag.txt ]
do

PASSWORD=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/secrets/"${HELMRELEASE}"-es-elastic-user | grep  '"elastic":' | awk '{ print $2 }' | sed 's/"//g')

PW=$(echo -n  $PASSWORD | base64 -d )

x=$(curl -ku  elastic:$PW https://$LB:$PORT/_cluster/health?pretty | grep '"status"' | awk ' { print $3 } ' | sed 's/"//g' | sed 's/,//g')

curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X PUT -d '{ "apiVersion": "v1","data": {"elastic": "TnNjX0Vsaw=="},"kind": "Secret","metadata": {"name": "'$HELMRELEASE'-es-elastic-user"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/secrets/"${HELMRELEASE}"-es-elastic-user -s

if [ "$x" == "green" ]; then
  bash /opt/backup_script.sh
  touch /tmp/flag.txt
fi
done

###############    To get the status of both Elasticsearch And Kibana ##################
while true
do
  curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X PUT -d '{ "apiVersion": "v1","data": {"elastic": "TnNjX0Vsaw=="},"kind": "Secret","metadata": {"name": "'$HELMRELEASE'-es-elastic-user"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/secrets/"${HELMRELEASE}"-es-elastic-user -s

  ######------- To generate one configmapwhich displays elasticsearch status --------############
  ######------- LB,PORT refers to Elasticsearch & LB1,PORT1 refers to Kibana -------############

  LB=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${HELMRELEASE}"-es-http |  grep 'hostname' | awk '{print $2}' | sed 's/",//g' | sed 's/"//g')

  LB1=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${KIBANA}"-kb-http |  grep 'hostname' | awk '{print $2}' | sed 's/",//g' | sed 's/"//g')

  PORT=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${HELMRELEASE}"-es-http | grep '"port":' | awk '{print $2}' | sed s/,//g)

  PORT1=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/services/"${KIBANA}"-kb-http | grep '"port":' | awk '{print $2}' | sed s/,//g)

  if [ -z "$LB" ];then
    LB="${HELMRELEASE}-es-http.${NAMESPACE}.svc.cluster.local"
    PORT=9200
  fi

  if [ -z "$LB1" ];then
    LB1="${KIBANA}-kb-http.${NAMESPACE}.svc.cluster.local"
    PORT1=5601
  fi

    #######-------Elasticsearch service details-------#######

  curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X PUT -d '{ "apiVersion": "v1","data": {"elastic": "TnNjX0Vsaw=="},"kind": "Secret","metadata": {"name": "'$HELMRELEASE'-es-elastic-user"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/secrets/"${HELMRELEASE}"-es-elastic-user

  PASSWORD=$(curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/secrets/"${HELMRELEASE}"-es-elastic-user | grep  '"elastic":' | awk '{ print $2 }' | sed 's/"//g')

  PW=$(echo -n  $PASSWORD | base64 -d )

  x=$(curl -ku  elastic:$PW https://$LB:$PORT/_cluster/health?pretty | grep '"status"' | awk ' { print $3 } ' | sed 's/"//g' | sed 's/,//g')

  if [ "$x" == "green" ];
  then
            STATUS="UP"
            MSG="Instance server is connected successful"
            ERR="False"
  elif [ "$x" == "yellow" ];
  then
            STATUS="Partially UP"
            MSG="Instance server is connected successful but it is not highly available."
            ERR="False"
  else
            STATUS="Down"
            MSG="Instance server is not connected"
            ERR="True"
  fi

  V=$(curl -ku  elastic:$PW https://$LB:$PORT/ | grep '"number"'  | awk ' { print $3 } ' | sed 's/"//g' | sed 's/,//g')

  flag=$(curl ${GIP})
  if [ "$flag" == "Client sent an HTTP request to an HTTPS server." ]
  then
    request=https
  else
    request=http
  fi
  curl -k $request://<username>:<password>@$GIP/api/orgs?perpage=0 > /tmp/gorg.txt     # Repalce username,password with Grafana credentials
  sed -i 's/{/\n/g' /tmp/gorg.txt
  sed -i 's/,/\n/g' /tmp/gorg.txt
  cat /tmp/gorg.txt |grep "id" /tmp/gorg.txt | cut -d ":" -f2- | sed 's/"//g' | while read N
  do
    curl -k -X POST $request://<username>:<password>@$GIP/api/user/using/$N
    curl -k $request://<username>:<password>@$GIP/api/search?query=$TITLE > /tmp/gtest.txt
    sed -i 's/{/\n/g' /tmp/gtest.txt
    sed -i 's/}/\n/g' /tmp/gtest.txt
    value=$(cat /tmp/gtest.txt | grep '"folderTitle":"'"$NAMESPACE"'"' | sed 's/,/\n/g' | grep url | cut -d ":" -f2- | sed 's/"//g')
    if [ ! -z "$value" ]
    then
      dashboardurl=$request://$GIP$value?orgId=$N
      echo "$dashboardurl" > /tmp/gurl.txt
    else
      echo "NO Dashbaord Found" > /tmp/gurl.txt
    fi
  done
  dashboardurl=$(cat /tmp/gurl.txt)

  curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/configmaps/"${HELMRELEASE}"-status-config-map > /tmp/cmcheck.txt

  CM=$(grep "not found" /tmp/cmcheck.txt | awk '{print $4 $5}' |  sed 's/",//g')

  if [[ "$CM" == "notfound" ]]
  then
          curl  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X POST -d '{"kind": "ConfigMap", "apiVersion": "v1", "metadata": {"name":"'"${HELMRELEASE}"'-status-config-map"}, "data": {"status": "'"${STATUS}"'", "message": "'"${MSG}"'", "error": "'"${ERR}"'", "grafanaDashboardUrl": "'"${dashboardurl}"'", "loggingDashboardUrl": "", "appVersion": "'"${V}"'", "urls": "'"{"'\"'${HELMRELEASE}'-es-http\"'": "'\"https://'${LB}':'${PORT}'\"'"}"'"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/configmaps -k

  else
          curl  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X PUT -d '{"kind": "ConfigMap", "apiVersion": "v1", "metadata": {"name":"'"${HELMRELEASE}"'-status-config-map"}, "data": {"status": "'"${STATUS}"'", "message": "'"${MSG}"'", "error": "'"${ERR}"'", "grafanaDashboardUrl": "'"${dashboardurl}"'", "loggingDashboardUrl": "", "appVersion": "'"${V}"'", "urls": "'"{"'\"'${HELMRELEASE}'-es-http\"'": "'\"https://'${LB}':'${PORT}'\"'"}"'"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/configmaps/"${HELMRELEASE}"-status-config-map -k

  fi
  sleep 60

  #######------Kibana service details-----######

  KIBANA="${HELMRELEASE_KIBANA}"

  x1=$(curl -XGET -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/yaml" -H "Accept: application/yaml, */*" https://"${kubeApiServerIp}":"${kubeApiPort}"/apis/kibana.k8s.elastic.co/v1/namespaces/$NAMESPACE/kibanas | grep health | awk ' NR==2 { print $2 } ')

  if [ "$x1" == "green" ];
  then
            STATUS="UP"
            MSG="Instance server is connected to elasticsearch"
            ERR="False"
  else
            STATUS="Down"
            MSG="Instance server is not connected to elasticsearch/Server is not running"
            ERR="True"
  fi

  curl -k --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/configmaps/"${KIBANA}"-status-config-map > /tmp/kibanacmcheck.txt

  CM1=$(grep "not found" /tmp/kibanacmcheck.txt | awk '{print $4 $5}' |  sed 's/",//g')

  if [[ "$CM1" == "notfound" ]]
  then
          curl  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X POST -d '{"kind": "ConfigMap", "apiVersion": "v1", "metadata": {"name":"'"${KIBANA}"'-status-config-map"}, "data": {"status": "'"${STATUS}"'", "message": "'"${MSG}"'", "error": "'"${ERR}"'", "grafanaDashboardUrl": "", "loggingDashboardUrl": "", "appVersion": "'"${V}"'", "urls": "'"{"'\"'${KIBANA}'-kb-http\"'": "'\"https://'${LB1}':'${PORT1}'\"'"}"'"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/configmaps -k

  else
          curl  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Content-Type: application/json" -H "Accept: application/json, */*" -X PUT -d '{"kind": "ConfigMap", "apiVersion": "v1", "metadata": {"name":"'"${KIBANA}"'-status-config-map"}, "data": {"status": "'"${STATUS}"'", "message": "'"${MSG}"'", "error": "'"${ERR}"'", "grafanaDashboardUrl": "", "loggingDashboardUrl": "", "appVersion": "'"${V}"'", "urls": "'"{"'\"'${KIBANA}'-kb-http\"'": "'\"https://'${LB1}':'${PORT1}'\"'"}"'"}}' https://"${kubeApiServerIp}":"${kubeApiPort}"/api/v1/namespaces/$NAMESPACE/configmaps/"${KIBANA}"-status-config-map -k
  fi

done
