#!/bin/bash

[[ "TRACE" ]] && set -x

if [ $ENABLE_KUBERNETES == 'false' -o $ENABLE_KUBERNETES == '' ]
then
 source /configg/hive/config
fi

: ${ENABLE_HIVE_SSL:=false}
: ${HADOOP_INSTALL:=/usr/local/hadoop}
: ${MASTER:=hdfs-master}
: ${DOMAIN_NAME:=cloud.com}
: ${DOMAIN_REALM:=$DOMAIN_NAME}
#: ${HDFS:=hdfs-master.cloud.com}
: ${KEY_PWD:=sumit@1234}
: ${ENABLE_HADOOP_SSL:=false}
: ${ENABLE_KERBEROS:=false}
: ${ENABLE_KUBERNETES:=false}
#: ${NAME_SERVER:=hdfs-master.cloud.com}
: ${HDFS_MASTER:=$MASTER.$DOMAIN_NAME}
: ${REALM:=$(echo $DOMAIN_NAME | tr 'a-z' 'A-Z')}
: ${HADOOP_OPTION:=-s}

startSsh() {
 echo -e "Starting SSHD service"
 /usr/sbin/sshd
}

setEnvVariable() {
 export HIVE_HOME="/usr/local/hive"
 export HIVE_CONF_DIR="/usr/local/hive/conf"
 export PATH="$HIVE_HOME/bin:$PATH"
 export CLASSPATH="$CLASSPATH:/usr/local/hadoop/lib/*:."
 export CLASSPATH="$CLASSPATH:/usr/local/hive/lib/*:."
 export DERBY_INSTALL="/usr/local/derby"
 export CLASSPATH="$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:."
 export PATH="$PATH:$DERBY_INSTALL/bin"

 fqdn=$(hostname -f)
 #mkdir /hive
 echo 'export HIVE_HOME=/usr/local/hive' >> /etc/bash.bashrc
 echo 'export HIVE_CONF_DIR=/usr/local/hive/conf' >> /etc/bash.bashrc
 echo 'export PATH=$HIVE_HOME/bin:$PATH' >> /etc/bash.bashrc
 echo 'export CLASSPATH=$CLASSPATH:/usr/local/hadoop/lib/*:.' >> /etc/bash.bashrc
 echo 'export CLASSPATH=$CLASSPATH:/usr/local/hive/lib/*:.' >> /etc/bash.bashrc
 echo 'export DERBY_INSTALL=/usr/local/derby' >> /etc/bash.bashrc
 echo 'export CLASSPATH=$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.' >> /etc/bash.bashrc
 echo 'export PATH=$PATH:$DERBY_INSTALL/bin' >> /etc/bash.bashrc

 echo 'mkdir -p $HOME/hive' >> /etc/bash.bashrc
 echo 'chmod 700 $HOME/hive' >> /etc/bash.bashrc
 echo 'cd $HOME/hive' >> /etc/bash.bashrc >> /etc/bash.bashrc
 echo 'echo "1. Run => schematool -dbType derby -initSchema"' >> /etc/bash.bashrc
 echo 'echo "2. Run => hive =>Standalone Mode => Cntl+C to quit"' >> /etc/bash.bashrc
 echo 'echo "2. Run => hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console"' >> /etc/bash.bashrc
}

changeOwner() {
 chown -R root:hadoop /usr/local/hive
}

initializePrincipal() {
 kadmin -p root/admin -w admin -q "addprinc -randkey hive/$(hostname -f)@$REALM"
 
 kadmin -p root/admin -w admin -q "xst -k hive.keytab hive/$(hostname -f)@$REALM"

 mkdir -p /etc/security/keytabs
 mv hive.keytab /etc/security/keytabs
 chmod 400 /etc/security/keytabs/hive.keytab
 chown root:hadoop /etc/security/keytabs/hive.keytab
}

setupKerberosSsl(){
  fqdn=$(hostname -f)
  if [ $ENABLE_KERBEROS == 'true' ]
  then
    sed -i "s/\$HIVE_KEYTAB/<value>\/etc\/security\/keytabs\/hive.keytab<\/value>/g" /usr/local/hive/conf/hive-site.xml
    sed -i "s/\$HIVE_PRINCIPAL/<value>hive\/$fqdn@$REALM<\/value>/g" /usr/local/hive/conf/hive-site.xml
    sed -i "s/\$AUTHENTICATION_TYPE/<value>KERBEROS<\/value>/g" /usr/local/hive/conf/hive-site.xml
  else
    sed -i "s/\$HIVE_KEYTAB/<value\/>/g" /usr/local/hive/conf/hive-site.xml
    sed -i "s/\$HIVE_PRINCIPAL/<value>hive-metastore\/_HOST@EXAMPLE.COM<\/value>/g" /usr/local/hive/conf/hive-site.xml
    sed -i "s/\$AUTHENTICATION_TYPE/<value>NONE<\/value>/g" /usr/local/hive/conf/hive-site.xml
  fi

  if [ $ENABLE_HIVE_SSL == 'true' ]
  then
   sed -i "s/\$ENABLE_SASL/<value>true<\/value>/g" /usr/local/hive/conf/hive-site.xml
  else
   sed -i "s/\$ENABLE_SASL/<value>false<\/value>/g" /usr/local/hive/conf/hive-site.xml
  fi
}

startHive() {
 su - root -c "/usr/local/hive/bin/schematool -dbType derby -initSchema"
 su - root -c "/usr/local/hive/bin/hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console"
}

deamon() {
  while true; do sleep 1000; done
}

bashPrompt() {
 /bin/bash
}

sshPromt() {
 /usr/sbin/sshd -D
}

initialize() {
 startHive
}

#/utility/hadoop/bootstrap.sh -s master : setup hadoop as master
#/utility/hadoop/bootstrap.sh -s slave: setup hadoop as slave
#/utility/hadoop/bootstrap.sh -a master: start hadoop as master
#/utility/hadoop/bootstrap.sh -a slave: start hadoop as slave

setupHive(){
    /utility/hadoop/bootstrap.sh $HADOOP_OPTION $1
    if [ "$ENABLE_KERBEROS" == 'true' ]
    then
      initializePrincipal
    fi
    #changeOwner
    setEnvVariable
}

main() {

 if [ $1 == '-s' -a ! -f /hive_installed ]
 then
    setupHive $2
    touch /hive_installed
    exit 0
 fi
 if [ ! -f /hive_initialized ]; then
    setupHive $2
    startSsh
    initialize
    touch /hive_initialized
  else
    startSsh
    initialize
  fi
  if [[ $1 == "-d" ]]; then
   deamon
  fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
