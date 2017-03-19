FROM centos:centos7

MAINTAINER Shea Stewart <shea.stewart@arctiq.ca>


USER root 
ENV PKG_CONFIG_PATH=/usr/lib:/usr/local/lib

# Prepare for systemd first
ENV container docker
RUN yum -y update; yum clean all
RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Basic packages
RUN yum install -y epel-release \
  && yum clean all \
  && yum -y install passwd sudo git wget openssl openssh openssh-server openssh-clients socat git autoconf automake gcc cmake install yajl-devel install boost boost-devel libselinux-devel libmount-devel golang-github-cpuguy83-go-md2man

# Redis
RUN yum install -y redis 

RUN git clone https://github.com/projectatomic/oci-systemd-hook \ 
  && cd oci-systemd-hook \
  && autoreconf -i \
  && ./configure --libexecdir=/usr/libexec/oci/hooks.d \ 
  && make \ 
  && make install

# RabbitMQ
#RUN yum install -y erlang \
#  && rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc \
#  && rpm -Uvh https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_7/rabbitmq-server-3.6.7-1.el7.noarch.rpm


#ADD config/rabbitmq.config /etc/rabbitmq/
#RUN rabbitmq-plugins enable rabbitmq_management

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
ADD config/supervisord.conf /etc/supervisord.conf

EXPOSE 22 3000 4567 5671 15672

#CMD ["/usr/bin/supervisord"]
CMD ['/sbin/init']