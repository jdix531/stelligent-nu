#!/bin/bash

# set -ex

export AWS_REGION=us-east-2
export AWS_PAGER=''
export AWS_VAULT_PROMPT=terminal
aws_sl='aws-vault exec stelligent_labs -- aws'
stack_name='lab-6-1-2-jdix'

done="DONE"

if [[ -z $1 || ( $1 != 'up' && $1 != 'down' ) ]] ; then
    echo 'up or down'
    exit 1
fi

if [ $1 == 'up' ]; then
    $aws_sl cloudformation deploy --stack-name $stack_name --template-file cfn.yaml --parameter-overrides file://params.json --capabilities CAPABILITY_NAMED_IAM
    # $aws_sl cloudformation wait stack-create-complete --stack-name $stack_name
    echo $done
elif [ $1 == 'down' ]; then
    $aws_sl cloudformation delete-stack --stack-name $stack_name
    $aws_sl cloudformation wait stack-delete-complete --stack-name $stack_name
    echo $done
fi


# --launch-template 'LaunchTemplateId=lt-0ba2acee505b1bcee,Version=$Latest' \
# aws-sl autoscaling \
# create-auto-scaling-group \
# --auto-scaling-group-name myAsg \
# --instance-id i-0373e799f8620ad0a \
# --min-size 1 \
# --max-size 2 \
# --desired-capacity 1
