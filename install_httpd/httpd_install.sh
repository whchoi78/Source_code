#! /bin/bash

yum -y update
yum -y install make gcc gcc-c++ pcre-devel expat-devel

src_dir=/usr/local/src
install_dir=/home #edit me
 
pcre=pcre-8.45 #edit me
pcre_version="${pcre#*-}"
httpd=httpd-2.4.46 #edit me
apr=apr-1.7.4 #edit me
apr_util=apr-util-1.6.3 #edit me
mod_jk=tomcat-connectors-1.2.49-src #edit me

cd $src_dir

wget https://sourceforge.net/projects/pcre/files/pcre/$pcre_version/$pcre.tar.gz -P $src_dir
wget http://archive.apache.org/dist/httpd/$httpd.tar.gz -P $src_dir
wget https://downloads.apache.org/apr/$apr.tar.gz -P $src_dir
wget https://downloads.apache.org/apr/$apr_util.tar.gz -P $src_dir
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/$mod_jk.tar.gz -P $src_dir

tar zxvf $pcre.tar.gz
tar zxvf $httpd.tar.gz
tar zxvf $apr.tar.gz
tar zxvf $apr_util.tar.gz
tar zxvf $mod_jk.tar.gz

cd $src_dir/$pcre
./configure --prefix=/home/$pcre
make && make install

mv $src_dir/$apr $src_dir/$httpd/srclib/apr
mv $src_dir/$apr_util $src_dir/$httpd/srclib/apr-util

cd $src_dir/$httpd
./configure --prefix=$install_dir/$httpd --with-included-apr --with-pcre=$install_dir/$pcre/bin/pcre-config
make && make install

echo "[Unit]" >> /usr/lib/systemd/system/httpd.service
echo "Description=Apache Service" >> /usr/lib/systemd/system/httpd.service
echo "[Service]" >> /usr/lib/systemd/system/httpd.service
echo "Type=forking" >> /usr/lib/systemd/system/httpd.service
echo "PIDFile=${install_dir}/${httpd}/logs/httpd.pid" >> /usr/lib/systemd/system/httpd.service
echo "ExecStart=${install_dir}/${httpd}/bin/apachectl start" >> /usr/lib/systemd/system/httpd.service
echo "ExecReload=${install_dir}/${httpd}/bin/apachectl graceful" >> /usr/lib/systemd/system/httpd.service
echo "ExecStop=${install_dir}/${httpd}/bin/apachectl stop" >> /usr/lib/systemd/system/httpd.service
echo "KillSignal=SIGCONT" >> /usr/lib/systemd/system/httpd.service
echo "PrivateTmp=true" >> /usr/lib/systemd/system/httpd.service
echo "[Install]" >> /usr/lib/systemd/system/httpd.service
echo "WantedBy=multi-user.target" >> /usr/lib/systemd/system/httpd.service

cd $src_dir/$mod_jk/native
./configure --with-apxs=$install_dir/$httpd/bin/apxs
make && make install

sed -i'' -r -e "/LoadModule rewrite_module modules\/mod_rewrite.so/a\LoadModule jk_module modules\/mod_jk.so" $install_dir/$httpd/conf/httpd.conf
echo "<IfModule jk_module>" >> $install_dir/$httpd/conf/httpd.conf
echo "Include conf/mod_jk.conf" >> $install_dir/$httpd/conf/httpd.conf
echo "</IfModule jk_module>" >> $install_dir/$httpd/conf/httpd.conf

wget https://github.com/whchoi78/Source_code/blob/de2c4731eab92bd0894322f54ca5d2a68e7425fb/install_httpd/conf/mod_jk.conf -P $install_dir/$httpd/conf/
wget https://github.com/whchoi78/Source_code/blob/de2c4731eab92bd0894322f54ca5d2a68e7425fb/install_httpd/conf/uriworkermap.properties -P $install_dir/$httpd/conf/
wget https://github.com/whchoi78/Source_code/blob/de2c4731eab92bd0894322f54ca5d2a68e7425fb/install_httpd/conf/workers.properties -P $install_dir/$httpd/conf/

systemctl daemon-reload
systemctl start httpd
systemctl enable httpd