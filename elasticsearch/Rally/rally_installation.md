**Prerequisites:**
```
sudo apt update
sudo apt-get install gcc python3-pip python3-dev
sudo apt install git
sudo apt install default-jdk
```
**Adding all the installed packages to the path for better run and not to get into any Unknown Issues**
```
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
PATH=/usr/bin/python3:$PATH
PATH=/usr/lib/jvm/java-11-openjdk-amd64:$PATH
PATH=/home/vineeth/.local/bin:$PATH
``` 
**Rally Installation**
```
sudo pip3 install esrally
```

**Running the Benchmark**
```
esrally race --track=metricbeat --track-params=number_of_shards:1,number_of_replicas:1,bulk_size:32000,bulk_indexing_clients:64 --pipeline=benchmark-only --target-hosts=benchmarking-cluster-2-es-http.elk.svc:9200 --client-options=timeout:60,use_ssl:true,verify_certs:false,basic_auth_user:'elastic',basic_auth_password:'benchmarking-1',ca_certs:'/cert/elastic-certificate.pem'
```
