FROM master.cloud.com:5000/hadoop
MAINTAINER Sumit Kumar Maji

WORKDIR /usr/local/
ARG REPOSITORY_HOST

ADD . /container/


ENV HIVE_HOME /usr/local/hive
ENV HIVE_CONF_DIR /usr/local/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH
ENV CLASSPATH $CLASSPATH:/usr/local/hadoop/lib/*:.
ENV CLASSPATH $CLASSPATH:/usr/local/hive/lib/*:.

#Derby Environemtn Setup
ENV DERBY_INSTALL /usr/local/derby
ENV CLASSPATH $DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.
ENV PATH $PATH:$DERBY_INSTALL/bin

RUN /container/setup.sh

EXPOSE 10000 10001
CMD /usr/sbin/sshd -D

