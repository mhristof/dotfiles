#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

""" """

import argparse
import boto3
from functools import cache
import time
import atexit


@cache
def get_all_instance_ids(region):
    ec2 = boto3.client("ec2", region_name=region)
    ssm = boto3.client("ssm", region_name=region)
    response = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )
    instances = {}

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            status = ssm.get_connection_status(Target=instance["InstanceId"])["Status"]

            if status != "connected":
                print(f"Instance {instance['InstanceId']} not connected, {status}")

                continue

            try:
                name = [
                    tag["Value"] for tag in instance["Tags"] if tag["Key"] == "Name"
                ][0]
            except IndexError:
                name = instance["InstanceId"]

            instances[instance["InstanceId"]] = name

    return instances


def main():
    parser = argparse.ArgumentParser(description="Run a command on a remote server")
    parser.add_argument("--ssm-doc", help="SSM Document")
    parser.add_argument("--name", help="Instance name")
    parser.add_argument(
        "-a", "--all", help="Run command on all instances", action="store_true"
    )
    parser.add_argument(
        "-r", "--region", help="Region", default=boto3.session.Session().region_name
    )
    parser.add_argument("-t", "--timeout", help="Timeout", default=30)

    args = parser.parse_args()
    ssm = boto3.client("ssm")

    if args.ssm_doc:
        try:
            document = ssm.get_document(Name=args.ssm_doc)
        except:
            raise Exception("Document not found")

    all_instances = get_all_instance_ids(args.region)

    if args.all:
        instances = all_instances
        print(f"running command on {len(instances)} instances")
    else:
        all_instances = get_all_instance_ids(args.region)

        if args.name not in all_instances.values():
            raise Exception(f"Instance with name {args.name} not found")

        instances = {k: v for k, v in all_instances.items() if v == args.name}

    # run the command
    response = ssm.send_command(
        InstanceIds=list(instances.keys()),
        DocumentName=args.ssm_doc,
        TimeoutSeconds=int(args.timeout),
    )

    def cancel():
        ssm.cancel_command(CommandId=response["Command"]["CommandId"])
        print("Command cancelled")

    atexit.register(cancel)

    results = {}

    while True:
        for invocation in ssm.list_command_invocations(
            CommandId=response["Command"]["CommandId"]
        )["CommandInvocations"]:
            status = invocation["Status"]
            status_details = invocation["StatusDetails"]
            instance_id = invocation["InstanceId"]

            if results.get(invocation["InstanceId"]) != status:
                print(
                    f"Instance {all_instances[instance_id]}: {results.get(instance_id)} -> {status}"
                )

                results[instance_id] = status

                continue

        done = {k: v for k, v in results.items() if v == "Failed" or v == "Success"}

        if len(done) == len(instances):
            break

        pending = [v for k, v in instances.items() if k not in done]
        print(
            f"Waiting for {len(instances) - len(done)} instances to finish: {pending}"
        )
        time.sleep(5)

    failed = [k for k, v in results.items() if v == "Failed"]

    if failed:
        raise Exception(f"Command failed on {len(failed)} instances: {failed}")

    pass


if __name__ == "__main__":
    main()
