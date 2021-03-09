#!/bin/bash

# set -ex

export AWS_REGION=us-east-2
export AWS_PAGER=''
export AWS_VAULT_PROMPT=terminal
aws_sl='aws-vault exec stelligent_labs -- aws'
stack_name='lab-5-4-2-jdix'

done="DONE"

if [[ -z $1 || ( $1 != 'up' && $1 != 'down' ) ]] ; then
    echo 'up or down'
    exit 1
fi

if [ $1 == 'up' ]; then
    $aws_sl cloudformation deploy --stack-name $stack_name --template-file cfn.yaml --parameter-overrides file://params.json --capabilities CAPABILITY_NAMED_IAM
    $aws_sl cloudformation wait stack-create-complete --stack-name $stack_name
    echo $done
elif [ $1 == 'down' ]; then
    $aws_sl cloudformation delete-stack --stack-name $stack_name
    $aws_sl cloudformation wait stack-delete-complete --stack-name $stack_name
    # aws-sl ec2 describe-instances --instance-ids i-089a8254beea7857e --region us-east-2
    # aws-sl ec2 create-snapshot --volume-id vol-0f770f6905f6ac7fb
    # aws-sl ec2 create-snapshot --volume-id vol-0f770f6905f6ac7fb
    # {
    #     "Description": "",
    #     "Encrypted": false,
    #     "OwnerId": "324320755747",
    #     "Progress": "",
    #     "SnapshotId": "snap-0dff546436b482c78",
    #     "StartTime": "2021-03-05T01:38:33+00:00",
    #     "State": "pending",
    #     "VolumeId": "vol-0f770f6905f6ac7fb",
    #     "VolumeSize": 3,
    #     "Tags": []
    # }
    # aws-sl ec2 describe-snapshots --snapshot-ids snap-0dff546436b482c78
    # {
    #     "Snapshots": [
    #         {
    #             "Description": "",
    #             "Encrypted": false,
    #             "OwnerId": "324320755747",
    #             "Progress": "100%",
    #             "SnapshotId": "snap-0dff546436b482c78",
    #             "StartTime": "2021-03-05T01:38:33.419000+00:00",
    #             "State": "completed",
    #             "VolumeId": "vol-0f770f6905f6ac7fb",
    #             "VolumeSize": 3
    #         }
    #     ]
    # }
    echo $done
fi
