**1.automate-deployment-role.yaml**

    This file is to create a role for the automation deployment we are using.


**2.automate_deployment.yaml**
   
    This is the automation file where we are changing the default **Elastic password, getting the Elasticsearch and Kibana service status, Taking regural Backups etc..,**


**3.backup_pvc.yaml**

    This helps to create a pvc where we can store our **backdup data and logs.**


**4.elastic-licence.yaml**

    When you have Elasticsearch Licence/want to try out trial licence , this yaml will be useful.


**5.elasticsearch.yaml**

    This is the main file which can be used to deploy **Elasticsearch.**


**6.external-certs.yaml**

    This is to replace the default certificates with the certs we have generated.


**7.grafana-dashboard-cm.yaml**

    This is thecm file which will take the grafana.json from the **Configmap** directory.


**8.grafana-dashboard.yaml**

    This file helps to create Elasticsearch Dashboard directly to the Grafana.


**9.input-config.yaml**

    This file is not mandatory.


**10.keycloak-cert.yaml**

    This is used when Elasticsearch is integrated with keyclaok for more security.


**11.log4j.yaml**

    This file helps to forward logs to a file inside **"/usr/share/elasticsearch/logs"** directory


**12.oidc-secret.yaml**

    Here we pass the keyclaok secret token.


**13.prometheus-alerts.yaml**

    This will generate alerts which are required for the elasticsearch to be monitored in the Prometheus.
