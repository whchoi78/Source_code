#! /bin/bash

#1-1) httpd 프로세스 동작 여부 확인 / 켜져 있으면 Script 실행 중지
if netstat -tuln | grep ':80 ' > /dev/null 2>&1; then
  echo "httpd 종료 후 실행 하세요!"
  exit 1
else  
#1-2) httpd 프로세스 중지 시 업데이트 시작
#2) 레포 업데이트 및 관련 패키지 설치
yum -y update
yum -y install make gcc gcc-c++ pcre-devel expat-devel

#3) 관련 패키지 다운로드 경로 지정 및 패키지 다운로드 / httpd 설치 경로 지정 / httpd 및 관련 패키지 버전 지정
src_dir=/usr/local/src/apache-2024 #사용자 수정 필요
install_dir=/home #사용자 수정 필요
origin_dir=/home/httpd-2.4.46 #사용자 수정 필요 

pcre=pcre-8.45 #사용자 수정 필요
pcre_version="${pcre#*-}"
httpd=httpd-2.4.59 #사용자 수정 필요
apr=apr-1.7.5 #사용자 수정 필요
apr_util=apr-util-1.6.3 #사용자 수정 필요
mod_jk=tomcat-connectors-1.2.49-src #사용자 수정 필요
service_file="/usr/lib/systemd/system/httpd.service"

mkdir $src_dir
cd $src_dir

wget https://sourceforge.net/projects/pcre/files/pcre/$pcre_version/$pcre.tar.gz -P $src_dir
wget https://archive.apache.org/dist/httpd/$httpd.tar.gz -P $src_dir
wget https://downloads.apache.org/apr/$apr.tar.gz -P $src_dir
wget https://downloads.apache.org/apr/$apr_util.tar.gz -P $src_dir
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/$mod_jk.tar.gz -P $src_dir

#3-2) 다운로드 받은 패키지 압축 해제
tar zxvf $src_dir/$pcre.tar.gz
tar zxvf $src_dir/$httpd.tar.gz
tar zxvf $src_dir/$apr.tar.gz
tar zxvf $src_dir/$apr_util.tar.gz
tar zxvf $src_dir/$mod_jk.tar.gz

#4) pcre 패키지 설치
cd $src_dir/$pcre
./configure --prefix=/$src_dir/$pcre
make && make install

#5) apr 및 apr_util 파일 httpd 파일 내 삽입
mv $src_dir/$apr $src_dir/$httpd/srclib/apr
mv $src_dir/$apr_util $src_dir/$httpd/srclib/apr-util

#6) httpd 설치
cd $src_dir/$httpd
./configure --prefix=$install_dir/$httpd --with-included-apr --with-pcre=$src_dir/$pcre/bin/pcre-config
make && make install

#7) 구 버전 httpd conf 파일 신 버전 httpd로 이관 
if [ -f "$origin_dir/conf/httpd.conf" ]; then
mkdir -p $install_dir/$httpd/conf/old
mv $install_dir/$httpd/conf/* $install_dir/$httpd/conf/old/
cp -r $origin_dir/conf/* $install_dir/$httpd/conf
fi

#7-2) 이관 받은 httpd 파일 경로 변경(구버전 경로 -> 신버전 경로)
sed -i "s|$origin_dir|$install_dir/$httpd|g" $install_dir/$httpd/conf/httpd.conf

#8) system 등록
if [ -f "$service_file" ]; then
cp $service_file $service_file.bak
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

#9) mod_jk 라이브러리 추가
cd $src_dir/$mod_jk/native
./configure --with-apxs=$install_dir/$httpd/bin/apxs
make && make install

#10) 시스템 시작
systemctl daemon-reload
systemctl start httpd
systemctl enable httpd
fi