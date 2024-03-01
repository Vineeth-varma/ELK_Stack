FROM ubuntu:18.04

ENV TERM=xterm

RUN apt-get update && apt-get install -y \
    vim \
    wget \
    openssh-server \
    sudo \
    cron \
    curl

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 755 ~/.ssh/authorized_keys

RUN echo 'elastic ALL=(ALL) NOPASSWD: /usr/sbin/useradd, /usr/sbin/groupadd, /bin/sed, /bin/echo, /usr/bin/sort, /bin/cat, /usr/bin/tee,  /usr/bin/bash, /bin/mkdir, /bin/cp, /bin/chown, /bin/chmod, /bin/bash, /usr/sbin/service, /usr/sbin/cron, /usr/bin/crontab, /usr/sbin/postfix' >> /etc/sudoers


#RUN mkdir /home/elastic
#RUN groupadd elastic
RUN useradd -ms /bin/bash elastic
#RUN mkdir /home/elastic
#RUN chown -R elastic: /home/elastic
RUN usermod -s /bin/bash elastic

RUN chmod 777 /opt

COPY myaddition.sh /opt
COPY backup_script.sh /opt/backup_script.sh

RUN chmod 777 /opt/myaddition.sh
RUN chmod 777 /opt/backup_script.sh

USER elastic
WORKDIR /home/elastic

ENTRYPOINT [ "/opt/myaddition.sh" ]
