FROM sumit/hadoop
MAINTAINER Sumit Kumar Maji

WORKDIR /usr/local/
ARG REPOSITORY_HOST

RUN wget "$REPOSITORY_HOST"/repo/apache-hive-2.3.2-bin.tar.gz &&\
tar -xzvf apache-hive-2.3.2-bin.tar.gz &&\
mv /usr/local/apache-hive-2.3.2-bin /usr/local/hive/ &&\
rm -rf /usr/local/apache-hive-2.3.2-bin.tar.gz &&\
chown -R root:hadoop /usr/local/hive &&\
wget "$REPOSITORY_HOST"/repo/db-derby-10.13.1.1-bin.tar.gz &&\
tar -xzvf db-derby-10.13.1.1-bin.tar.gz &&\
mv /usr/local/db-derby-10.13.1.1-bin /usr/local/derby &&\
rm -rf /usr/local/db-derby-10.13.1.1-bin.tar.gz &&\
chown -R root:hadoop /usr/local/derby &&\
wget "$REPOSITORY_HOST"/repo/spark-jar.tar.gz &&\
tar -xzvf /usr/local/spark-jar.tar.gz &&\
ln -s /usr/local/spark-jar/spark-network-common_2.11-2.2.0.jar /usr/local/hive/lib/spark-network-common_2.11-2.2.0.jar &&\
ln -s /usr/local/spark-jar/spark-core_2.11-2.2.0.jar /usr/local/hive/lib/spark-core_2.11-2.2.0.jar &&\
ln -s /usr/local/spark-jar/scala-library-2.11.8.jar /usr/local/hive/lib/scala-library-2.11.8.jar

RUN cp /usr/local/hive/conf/hive-env.sh.template /usr/local/hive/conf/hive-env.sh
RUN echo 'export HADOOP_HOME=/usr/local/hadoop' >> /usr/local/hive/conf/hive-env.sh

ENV HIVE_HOME /usr/local/hive
ENV HIVE_CONF_DIR /usr/local/hive/conf
ENV PATH $HIVE_HOME/bin:$PATH
ENV CLASSPATH $CLASSPATH:/usr/local/hadoop/lib/*:.
ENV CLASSPATH $CLASSPATH:/usr/local/hive/lib/*:.

#Derby Environemtn Setup
ENV DERBY_INSTALL /usr/local/derby
ENV CLASSPATH $DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.
ENV PATH $PATH:$DERBY_INSTALL/bin

RUN wget "$REPOSITORY_HOST"/repo/derby.jar
RUN wget "$REPOSITORY_HOST"/repo/derbyclient.jar

RUN mv derbyclient.jar /usr/local/hive/lib/derbyclient.jar
RUN mv derby.jar /usr/local/hive/lib/derby.jar

COPY config/hive-site.xml /usr/local/hive/conf/hive-site.xml
COPY config/jpox.properties /usr/local/hive/conf/jpox.properties
RUN mkdir -p /utility/hive/
COPY utility/bootstrap.sh /utility/hive/bootstrap.sh
RUN chown root:root /utility/hive/bootstrap.sh
RUN chmod +x /utility/hive//bootstrap.sh

EXPOSE 10000 10001 10002
#CMD /usr/sbin/sshd -D
ENTRYPOINT ["/utility/hive/bootstrap.sh"]
