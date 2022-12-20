#!/bin/bash

#What do you want back-up Delete instance?
#servername
servername[0]=""    # edit me

SlackWeb_hook=""    # edit me

#Total number of servers
TotalInstanceNu=1   # edit me
#for
logNu=`expr $TotalInstanceNu - 1`

#date
date +"%y-%m-%d"
date +%Y%m --date '1 months ago'
date_ago=$(date +%m --date '1 months ago')
#exe path
e_path="/root/shell/ncloud_cli/cli_linux/"
#instance_info path
path="/root/shell/ncloud_cli/cli_linux/instance_info"

#create json instance_info file
$e_path./ncloud server getServerInstanceList > $path/total.json

#create image info
$e_path/ncloud server getMemberServerImageList > $path/image_info.json

echo $(date +"%y%m%d") Start Delete Back-up------------------------------------------ >> $path/log.txt

for((i=0;i<$TotalInstanceNu;i++)) do

    #Get InstanceNo
    imageNo[i]=`cat $path/image_info.json | jq -r '.getMemberServerImageListResponse.memberServerImageList[] | select(.memberServerImageName == "'${servername[i]}-$date_ago'") | .memberServerImageNo' `


#Delete Image
    $e_path./ncloud server deleteMemberServerImages --memberServerImageNoList ${imageNo[i]}
    sleep 1s
        if [ $i -eq $logNu ];then

            #Get ImageInfo
            $e_path./ncloud server getMemberServerImageList > $path/image_info.json

            #log
            cat $path/image_info.json | jq -r '.getMemberServerImageListResponse.memberServerImageList[] | select(.memberServerImageStatusName == "terminating") | .memberServerImageName' >> $path/log.txt
            curl -X POST -H 'Content-type: application/json' --data '{"text":" '${servername[i]}-$date_ago' 삭제 완료."}' $SlackWeb_hook
        fi

    sleep 0.01s

done

echo ----------------------------------------------------------------------- >> $path/log.txt

sleep 5s

