#!/bin/bash

tar -xzvf /container/apache-hive-2.1.0-bin.tar.gz -C /usr/local/
mv /usr/local/apache-hive-2.1.0-bin /usr/local/hive/
rm -rf /container/apache-hive-2.1.0-bin.tar.gz
chown -R hduser:hadoop /usr/local/hive

export HIVE_HOME="/usr/local/hive"
export HIVE_CONF_DIR="/usr/local/hive/conf"
export PATH="$HIVE_HOME/bin:$PATH"
export CLASSPATH="$CLASSPATH:/usr/local/hadoop/lib/*:."
export CLASSPATH="$CLASSPATH:/usr/local/hive/lib/*:."

su - hduser -c "echo 'export HIVE_HOME=/usr/local/hive' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HIVE_CONF_DIR=/usr/local/hive/conf' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export PATH=$HIVE_HOME/bin:$PATH' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export CLASSPATH=$CLASSPATH:/usr/local/hadoop/lib/*:.' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export CLASSPATH=$CLASSPATH:/usr/local/hive/lib/*:.' >> /home/hduser/.bashrc"


su - hduser -c "cp /usr/local/hive/conf/hive-env.sh.template /usr/local/hive/conf/hive-env.sh"
su - hduser -c "echo 'export HADOOP_HOME=/usr/local/hadoop' >> /usr/local/hive/conf/hive-env.sh"

#Install Derby
tar -xzvf /container/db-derby-10.13.1.1-bin.tar.gz -C /usr/local/
mv /usr/local/db-derby-10.13.1.1-bin /usr/local/derby
rm -rf /container/db-derby-10.13.1.1-bin.tar.gz
chown -R hduser:hadoop /usr/local/derby

#Derby Environemtn Setup
export DERBY_INSTALL="/usr/local/derby"
export CLASSPATH="$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:."
export PATH="$PATH:$DERBY_INSTALL/bin"

echo 'export DERBY_INSTALL=/usr/local/derby' >> /home/hduser/.bashrc
echo 'export CLASSPATH=$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.' >> /home/hduser/.bashrc
echo 'export PATH=$PATH:$DERBY_INSTALL/bin' >> /home/hduser/.bashrc


cp /container/hive-site.xml /usr/local/hive/conf/hive-site.xml
cp /container/jpox.properties /usr/local/hive/conf/jpox.properties
cp /container/derbyclient.jar  /usr/local/hive/lib/derbyclient.jar
cp /container/derby.jar /usr/local/hive/lib/derby.jar

chown -R hduser:hadoop /usr/local/hive

echo 'cd /home/hduser' >> /home/hduser/.bashrc
echo 'echo "1. Run => schematool -dbType derby -initSchema"' >> /home/hduser/.bashrc
echo 'echo "2. Run => hive =>Standalone Mode => Cntl+C to quit"' >> /home/hduser/.bashrc
echo 'echo "2. Run => hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console"' >> /home/hduser/.bashrc

su - hduser -c "echo 'export BOOTSTRAP=/etc/bootstrap.sh' >> /home/hduser/.bashrc"

adduser --ingroup hadoop admin
adduser admin sudo

