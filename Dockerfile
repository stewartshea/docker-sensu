FROM centos:centos7

MAINTAINER Shea Stewart <shea.stewart@arctiq.ca>

# Basic packages
RUN yum install -y epel-release \
  && yum clean all \
  && yum -y install passwd sudo git wget openssl openssh openssh-server openssh-clients 

# Redis
RUN yum install -y redis \
    && systemctl start redis \ 

# RabbitMQ
RUN yum install -y erlang \
  && rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
  && rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.0/rabbitmq-server-3.6.0-1.noarch.rpm \


ADD config/rabbitmq.config /etc/rabbitmq/
RUN   systemctl start rabbitmq \
  && rabbitmq-plugins enable rabbitmq_management

# Sensu server
ADD config/sensu.repo /etc/yum.repos.d/
RUN yum clean all \ 
  && yum install -y sensu
ADD config/config.json /etc/sensu/
ADD config/redis.json /etc/sensu/conf.d/

# uchiwa
RUN yum install -y uchiwa
ADD config/uchiwa.json /etc/sensu/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py \
  && easy_install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

RUN systemctl start sshd

EXPOSE 22 3000 4567 5671 15672

CMD ["/usr/bin/supervisord"]
