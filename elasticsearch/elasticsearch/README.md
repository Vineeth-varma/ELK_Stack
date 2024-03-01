# Elasticsearch deployment through helm
### Charts

Under charts directory you can find Elasticsearch Exportor which is added as a dependency chart. This Exporter transport the ElasticSearch service metrics to Prometheus. 

***Note:***  Prometheus has to be deployed as we need prometheus Labels to connect both Elasticsearch and Prometheus.

### Chart.yaml 

In Chart.yaml I have added elasticsearch Exportor as dependency chart.

### Configmap

This directory is created mainly because I am passing grafana.json as a configmap to generate dashbaord directly into Grafana.

### Templates

Under templates you can find all the yamls related to Elasticsearch, Prometheus Alerts, Grafana Dashbaord, Automation Deployment, keyclaok files for oidc etc...,

### Values.yaml

It needs to be edited according to your cluster configurations and setup.

