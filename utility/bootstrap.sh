#!/bin/bash

[[ "TRACE" ]] && set -x

: ${HDFS:=hdfs-master}
: ${HIVE:=hive}
: ${SPARK:=spark}
: ${OOZIE:=oozie}

 ip_addr=`/sbin/ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'`

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
 kadmin -p root/admin -w admin -q "addprinc -randkey hive/$(hostname -f)@CLOUD.COM"
 
 kadmin -p root/admin -w admin -q "xst -k hive.keytab hive/$(hostname -f)@CLOUD.COM"

 mkdir -p /etc/security/keytabs
 mv hive.keytab /etc/security/keytabs
 chmod 400 /etc/security/keytabs/hive.keytab
 chown root:hadoop /etc/security/keytabs/hive.keytab
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

main() {
 if [ ! -f /hue_initialized ]; then
    /utility/ldap/bootstrap.sh
    startSsh
    initializePrincipal
    #changeOwner
    setEnvVariable
    initialize
    touch /hue_initialized
  else
    startSsh
    initialize
  fi
  if [[ $1 == "-d" ]]; then
   deamon
  fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
