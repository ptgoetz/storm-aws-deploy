# echo "127.0.0.1    localhost" > /etc/hosts

# apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install python-software-properties
add-apt-repository -y ppa:webupd8team/java
apt-get update
apt-get install -y supervisor unzip
apt-get install -y oracle-java8-installer

/etc/init.d/supervisor stop

groupadd storm
useradd --gid storm --home-dir /home/storm --create-home --shell /bin/bash storm

wget -N -P /tmp http://people.apache.org/~ptgoetz/$1.zip

unzip -o /tmp/$1.zip -d /usr/share/
chown -R storm:storm /usr/share/$1
ln -s /usr/share/$1 /usr/share/storm
ln -s /usr/share/storm/bin/storm /usr/bin/storm

mkdir /etc/storm
chown storm:storm /etc/storm

rm /usr/share/storm/conf/storm.yaml
cp /vagrant/storm.yaml /usr/share/storm/conf/
# cp /vagrant/cluster.xml /usr/share/storm/log4j2/
# cp /vagrant/worker.xml /usr/share/storm/log4j2/
ln -s /usr/share/storm/conf/storm.yaml /etc/storm/storm.yaml 

mkdir /var/log/storm
chown storm:storm /var/log/storm

# "s/\${host}/$FOO/g"
sed -i "s/\${host}/$2/g" /usr/share/storm/conf/storm.yaml

#sed -i 's/${storm.home}\/logs/\/var\/log\/storm/g' /usr/share/storm/logback/cluster.xml
