"""
Update or create a stack given a name and template + params
Original Author Søren B. Vrist (svrist)
https://gist.github.com/svrist/73e2d6175104f7ab4d201280acba049c
"""
from __future__ import division, print_function, unicode_literals

from datetime import datetime
import logging
import json
import sys

import boto3
import botocore
from botocore.exceptions import ValidationError

log = logging.getLogger('deploy.cf.create_or_update')  # pylint: disable=C0103


def deploy(stack_name, template, parameters, region, state):
    'Update or create stack'

    cf = boto3.client('cloudformation', region_name=region)  # pylint: disable=C0103

    template_data = _parse_template(template, cf)
    parameter_data = _parse_parameters(parameters)

    params = {
        'StackName': stack_name,
        'TemplateBody': template_data,
        'Parameters': parameter_data,
    }

    try:
        assert( state == 'up' or state == 'down')
    except ValidationError as e:
        print('state must be up or down for gist.deploy')
        raise(e)

    try:
        if state == 'up':
            if _stack_exists(stack_name, cf):
                print('Updating {}'.format(stack_name))
                stack_result = cf.update_stack(**params)
                waiter = cf.get_waiter('stack_update_complete')
            else:
                print('Creating {}'.format(stack_name))
                stack_result = cf.create_stack(**params)
                waiter = cf.get_waiter('stack_create_complete')
            print("...waiting for stack to be ready...")
            waiter.wait(StackName=stack_name)
        if state == 'down':
            if _stack_exists(stack_name, cf):
                print('Deleting {}'.format(stack_name))
                stack_result = cf.delete_stack(StackName=params['StackName'])
    except botocore.exceptions.ClientError as ex:
        error_message = ex.response['Error']['Message']
        if error_message == 'No updates are to be performed.':
            print("No changes")
        else:
            raise
    # else:
    #     print(json.dumps(
    #         cf.describe_stacks(StackName=stack_result['StackId']),
    #         indent=2,
    #         default=json_serial
    #     ))


def _parse_template(template, cf):
    with open(template) as template_fileobj:
        template_data = template_fileobj.read()
    cf.validate_template(TemplateBody=template_data)
    return template_data


def _parse_parameters(parameters):
    with open(parameters) as parameter_fileobj:
        parameter_data = json.load(parameter_fileobj)
    return parameter_data

def _stack_exists(stack_name, cf):
    paginator = cf.get_paginator('list_stacks')
    for page in paginator.paginate():
        for stack in page['StackSummaries']:
            if stack['StackStatus'] == 'DELETE_COMPLETE':
                continue
            if stack['StackName'] == stack_name:
                return True
    return False


def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""
    if isinstance(obj, datetime):
        serial = obj.isoformat()
        return serial
    raise TypeError("Type not serializable")


if __name__ == '__main__':
    deploy(*sys.argv[1:])