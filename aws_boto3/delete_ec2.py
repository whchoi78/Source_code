import boto3
import time

AWS_REGION = 'ap-northeast-2'

ec2 = boto3.resource('ec2',region_name=AWS_REGION)
ec2_client = boto3.client('ec2', region_name=AWS_REGION)

def main(name):
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
        instance_id = id

    return terminate_instance(instance_id)    

def terminate_instance(instance_id):
    terminate = ec2.Instance(instance_id)
    print(terminate) 



main('')