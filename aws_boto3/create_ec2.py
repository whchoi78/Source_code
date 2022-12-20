import boto3
import time

AWS_REGION = 'ap-northeast-2'
KEY_PAIR_NAME = 'AWS_study_key'
AMI_ID = 'ami-0b7d3a6732a357801'
SUBNET_ID = 'subnet-0483f7cee8a06292d'
SECURITYGROUP_ID = ['sg-0aaae6efb2be1022f']
INSTANCE_TYPE = 't3.small'
PUBLIC_IP = 'eipalloc-002e8a28b5c9f01eb'

ec2 = boto3.resource('ec2')
ec2_resource = boto3.resource('ec2', region_name=AWS_REGION)
ec2_client = boto3.client('ec2', region_name=AWS_REGION)

def main(name):
    instances = ec2.create_instances(
        ImageId= AMI_ID,        
        MinCount = 1,
        MaxCount = 1,
        InstanceType = INSTANCE_TYPE,
        KeyName = KEY_PAIR_NAME,
        SecurityGroupIds = SECURITYGROUP_ID,
        SubnetId = SUBNET_ID,
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': name
                    },
                    {
                        'Key': 'AutoStart',
                        'Value': 'True'
                    },
                    {
                        'Key': 'AutoStop',
                        'Value': 'True'
                    },
                        ]
            },
                    ],
    )

    print(instances)
    time.sleep(5)

    ids = ec2.instances.filter(
        Filters=[
         {
                'Name': 'tag:Name',
                'Values': [name]
            },
            {
                'Name': 'instance-state-name', 
                'Values': ['running']
            }
        ]
    )

    instance_id = ''

    for id in ids:
        instance_id=id.id
        
    
    return allocate_eip(instance_id)

def allocate_eip(instance):
   response = ec2_client.associate_address(AllocationId=PUBLIC_IP, InstanceId=instance)
   print(response)          

main('')