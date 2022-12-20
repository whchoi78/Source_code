import boto3

AWS_REGION = 'ap-northeast-2'

ec2 = boto3.resource('ec2',region_name=AWS_REGION)
ec2_client = boto3.client('ec2', region_name=AWS_REGION)
EIP_ID = 'eipalloc-01081407cea2dd2cb'

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

    instance_id = ' '
    for id in ids:
        instance_id = id.id
        #print('Instance ID: %s' % id.id)

        
    return allocate_eip(instance_id)    

def allocate_eip(instance):
     response = ec2_client.associate_address(AllocationId=EIP_ID, InstanceId=instance)
     print(response)
    
main('농협')