#!/bin/bash
#What do you want back-up instance?
#servername
servername[0]=""    # edit me


 #Total number of servers
 TotalInstanceNu=1  # edit me
 #for
 logNu=`expr $TotalInstanceNu - 1`

 SlackWeb_hook=""   # edit me

 #date
 date +"%y-%m-%d"
 month = $(date+"%m")
 #exe path
 e_path="/root/shell/ncloud_cli/cli_linux/"
 #instance_info path
 path="/root/shell/ncloud_cli/cli_linux/instance_info"

 #create json instance_info file
 $e_path./ncloud server getServerInstanceList > $path/total.json


 echo $(date +"%y%m%d%H%M%S") Start Back-up------------------------------------------------- >> $path/log.txt

for((i=0;i<$TotalInstanceNu;i++)) do
  #Get InstanceNo
  serverNo[i]=`cat $path/total.json | /bin/jq -r '.getServerInstanceListResponse.serverInstanceList[] | select(.serverName == "'${servername[i]}'") | .serverInstanceNo' `

      #Create Image
      $e_path/ncloud server createMemberServerImage --serverInstanceNo ${serverNo[i]} --memberServerImageName ${servername[i]}-$(date +"%m")


      if [ $i -eq $logNu ];then
          #Get ImageInfo
          $e_path/ncloud server getMemberServerImageList > $path/image_info.json

          for((j=0;j<$TotalInstanceNu;j++)) do
              #log
          cat $path/image_info.json | /bin/jq -r '.getMemberServerImageListResponse.memberServerImageList[] | select(.originalServerInstanceNo == "'${serverNo[j]}'") | .memberServerImageName' >> $path/log.txt
          servername=$(cat $path/image_info.json | /bin/jq -r '.getMemberServerImageListResponse.memberServerImageList[] | select(.originalServerInstanceNo == "'${serverNo[j]}'") | .memberServerImageName')
          curl -X POST -H 'Content-type: application/json' --data '{"text":" '${servername[i]}'-'$month' 이미지 생성 완료."}' $SlackWeb_hook
          done
      fi

      sleep 0.01s

  done

  echo $(date +"%y%m%d%H%M%S") END Back-up --------------------------------------------------- >> $path/log.txt

  sleep 5s
#finish