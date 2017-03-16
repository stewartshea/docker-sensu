FROM centos:centos7

MAINTAINER Shea Stewart <shea.stewart@arctiq.ca>


USER root 

# Basic packages
RUN yum install -y epel-release \
  && yum clean all \
  && yum -y install passwd sudo git wget openssl openssh openssh-server openssh-clients socat

# Redis
RUN yum install -y redis 

# RabbitMQ
RUN yum install -y erlang \
  && rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc \
  && rpm -Uvh https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_7/rabbitmq-server-3.6.7-1.el7.noarch.rpm


ADD config/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

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
