#!/bin/bash
aws_sl='aws-vault exec stelligent_labs -- aws'

aws_regions=( $(jq -r '.[][]' regions.json) )

if [[ ! -z $1 ]] && [[ $1 == 'up' || $1 == 'down' ]]; then
    for region in ${aws_regions[@]}; do
    if [ $1 == 'up' ]; then
        $aws_sl cloudformation deploy --template-file simple-s3-user.cfn.yaml --stack-name su-lab-$region-1-3-1-stack --parameter-overrides FriendlyName=joe-bucket --region $region
    elif [ $1 == 'down' ]; then
        $aws_sl cloudformation delete-stack --stack-name su-lab-$region-1-3-1-stack --region $region
    fi
    done
else
    echo "please set \$1 to 'up' or 'down' to spin stacks up or down."
    exit 1
fi
