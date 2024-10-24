#! /bin/bash

if netstat -tuln | grep ':80 ' > /dev/null 2>&1; then
  echo "httpd 종료 후 실행 하세요!"
  exit 1
else  
yum -y update
yum -y install make gcc gcc-c++ pcre-devel expat-devel

src_dir=/usr/local/src/apache-2024 #edit me
install_dir=/home #edit me
origin_dir=/home/httpd-2.4.46 #edit me 

pcre=pcre-8.45 #edit me
pcre_version="${pcre#*-}"
httpd=httpd-2.4.59 #edit me
apr=apr-1.7.5 #edit me
apr_util=apr-util-1.6.3 #edit me
mod_jk=tomcat-connectors-1.2.49-src #edit me
service_file="/usr/lib/systemd/system/httpd.service"

mkdir $src_dir
cd $src_dir

wget https://sourceforge.net/projects/pcre/files/pcre/$pcre_version/$pcre.tar.gz -P $src_dir
wget https://archive.apache.org/dist/httpd/$httpd.tar.gz -P $src_dir
wget https://downloads.apache.org/apr/$apr.tar.gz -P $src_dir
wget https://downloads.apache.org/apr/$apr_util.tar.gz -P $src_dir
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/$mod_jk.tar.gz -P $src_dir

tar zxvf $src_dir/$pcre.tar.gz
tar zxvf $src_dir/$httpd.tar.gz
tar zxvf $src_dir/$apr.tar.gz
tar zxvf $src_dir/$apr_util.tar.gz
tar zxvf $src_dir/$mod_jk.tar.gz

cd $src_dir/$pcre
./configure --prefix=/$src_dir/$pcre
make && make install

mv $src_dir/$apr $src_dir/$httpd/srclib/apr
mv $src_dir/$apr_util $src_dir/$httpd/srclib/apr-util

cd $src_dir/$httpd
./configure --prefix=$install_dir/$httpd --with-included-apr --with-pcre=$src_dir/$pcre/bin/pcre-config
make && make install

if [ -f "$origin_dir/conf/httpd.conf" ]; then
mkdir -p $install_dir/$httpd/conf/old
mv $install_dir/$httpd/conf/* $install_dir/$httpd/conf/old/
cp -r $origin_dir/conf/* $install_dir/$httpd/conf
fi

sed -i "s|$origin_dir|$install_dir/$httpd|g" $install_dir/$httpd/conf/httpd.conf

if [ -f "$service_file" ]; then
echo " " > $service_file
echo "[Unit]" >> $service_file
echo "Description=Apache Service" >> $service_file
echo "[Service]" >> $service_file
echo "Type=forking" >> $service_file
echo "PIDFile=${install_dir}/${httpd}/logs/httpd.pid" >> $service_file
echo "ExecStart=${install_dir}/${httpd}/bin/apachectl start" >> $service_file
echo "ExecReload=${install_dir}/${httpd}/bin/apachectl graceful" >> $service_file
echo "ExecStop=${install_dir}/${httpd}/bin/apachectl stop" >> $service_file
echo "KillSignal=SIGCONT" >> $service_file
echo "PrivateTmp=true" >> $service_file
echo "[Install]" >> $service_file
echo "WantedBy=multi-user.target" >> $service_file
fi

cd $src_dir/$mod_jk/native
./configure --with-apxs=$install_dir/$httpd/bin/apxs
make && make install

systemctl daemon-reload
systemctl start httpd
systemctl enable httpd
fi