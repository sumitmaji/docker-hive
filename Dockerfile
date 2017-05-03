FROM sumit/hadoop:latest
MAINTAINER Sumit Kumar Maji

COPY apache-hive-2.1.0-bin.tar.gz /usr/local/apache-hive-2.1.0-bin.tar.gz
RUN tar -xzvf /usr/local/apache-hive-2.1.0-bin.tar.gz -C /usr/local/
RUN mv /usr/local/apache-hive-2.1.0-bin /usr/local/hive/
RUN rm -rf /usr/local/apache-hive-2.1.0-bin.tar.gz
RUN chown -R hduser:hadoop /usr/local/hive

ENV HIVE_HOME /usr/local/hive
ENV HIVE_CONF_DIR /usr/local/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH
ENV CLASSPATH $CLASSPATH:/usr/local/hadoop/lib/*:.
ENV CLASSPATH $CLASSPATH:/usr/local/hive/lib/*:.

RUN su - hduser -c "echo 'export HIVE_HOME=/usr/local/hive' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export HIVE_CONF_DIR=/usr/local/hive/conf' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export PATH=$HIVE_HOME/bin:$PATH' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export CLASSPATH=$CLASSPATH:/usr/local/hadoop/lib/*:.' >> /home/hduser/.bashrc"
RUN su - hduser -c "echo 'export CLASSPATH=$CLASSPATH:/usr/local/hive/lib/*:.' >> /home/hduser/.bashrc"


RUN su - hduser -c "cp /usr/local/hive/conf/hive-env.sh.template /usr/local/hive/conf/hive-env.sh"
RUN su - hduser -c "echo 'export HADOOP_HOME=/usr/local/hadoop' >> /usr/local/hive/conf/hive-env.sh"
#Install Derby
COPY db-derby-10.13.1.1-bin.tar.gz /usr/local/db-derby-10.13.1.1-bin.tar.gz
RUN tar -xzvf /usr/local/db-derby-10.13.1.1-bin.tar.gz -C /usr/local/
RUN mv /usr/local/db-derby-10.13.1.1-bin /usr/local/derby
RUN rm -rf /usr/local/db-derby-10.13.1.1-bin.tar.gz
RUN chown -R hduser:hadoop /usr/local/derby

#Derby Environemtn Setup
ENV DERBY_INSTALL /usr/local/derby
ENV CLASSPATH $DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.
ENV PATH $PATH:$DERBY_INSTALL/bin

RUN echo 'export DERBY_INSTALL=/usr/local/derby' >> /home/hduser/.bashrc
RUN echo 'export CLASSPATH=$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.' >> /home/hduser/.bashrc
RUN echo 'export PATH=$PATH:$DERBY_INSTALL/bin' >> /home/hduser/.bashrc


COPY hive-site.xml /usr/local/hive/conf/hive-site.xml
COPY jpox.properties /usr/local/hive/conf/jpox.properties
COPY derbyclient.jar  /usr/local/hive/lib/derbyclient.jar
COPY derby.jar /usr/local/hive/lib/derby.jar

RUN chown -R hduser:hadoop /usr/local/hive

RUN echo 'cd /home/hduser' >> /home/hduser/.bashrc
RUN echo 'echo "1. Run => schematool -dbType derby -initSchema"' >> /home/hduser/.bashrc
RUN echo 'echo "2. Run => hive =>Standalone Mode => Cntl+C to quit"' >> /home/hduser/.bashrc
RUN echo 'echo "2. Run => hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console"' >> /home/hduser/.bashrc

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown hduser:hadoop /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh
RUN su - hduser -c "echo 'export BOOTSTRAP=/etc/bootstrap.sh' >> /home/hduser/.bashrc"

RUN adduser --ingroup hadoop admin
RUN adduser admin sudo


RUN apt-get update & apt-get install -y net-tools
EXPOSE 10000 10001
CMD /usr/sbin/sshd -D

