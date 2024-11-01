#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

"""

"""


import boto3
import sys
import re
from functools import cache


def main():

    src = sys.argv[1]
    dest = sys.argv[2]

    print(f"src: {src}, dest: {dest}")

    if src.startswith("lb:"):
        src_name = src.split(":")[1]
        src_id = lb(src_name)

        if src_id is None:
            print(f"src {src} not found")
            sys.exit(1)

        print(f"src_id: {src_id}")

        src_enis = find_eni("ELB app.*" + src_id.split("/")[-1])

        if src_enis is None:
            print(f"enis not found")
            sys.exit(1)

        print(f"enis: {src_enis}")

    if dest.startswith("ecs:"):

        dest_name = dest.split(":")[1]

        dest_enis = find_eni(ecs=dest_name)

        if dest_enis is None:
            print(f"enis not found")
            sys.exit(1)

        print(f"dest enis: {dest_enis}")

    ec2 = boto3.client("ec2")

    network_paths = ec2.describe_network_insights_paths()

    paths = {}

    for src_eni, src_az in src_enis.items():
        for dest_eni, dest_az in dest_enis.items():

            # create network insights path
            name = f"{src}/{src_az} -> {dest}/{dest_az}"

            for path in network_paths["NetworkInsightsPaths"]:
                pname = path["Tags"][0]["Value"]

                if pname == name:
                    print(f"deleting {name}")

                    for analysis in ec2.describe_network_insights_analyses()[
                        "NetworkInsightsAnalyses"
                    ]:

                        if (
                            analysis["NetworkInsightsPathId"]
                            != path["NetworkInsightsPathId"]
                        ):
                            continue

                        response = ec2.delete_network_insights_analysis(
                            NetworkInsightsAnalysisId=analysis[
                                "NetworkInsightsAnalysisId"
                            ]
                        )

                        if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
                            print(f"failed to delete analysis for {name}")
                            sys.exit(1)

                    try:
                        response = ec2.delete_network_insights_path(
                            NetworkInsightsPathId=path["NetworkInsightsPathId"]
                        )

                        if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
                            print(f"failed to delete {name}")
                            sys.exit(1)
                    except:
                        pass

            try:
                dest_port = dest.split(":")[2]
            except IndexError:
                dest_port = 80

            response = ec2.create_network_insights_path(
                Source=src_eni,
                Protocol="TCP",
                Destination=dest_eni,
                DestinationPort=dest_port,
                TagSpecifications=[
                    {
                        "ResourceType": "network-insights-path",
                        "Tags": [{"Key": "Name", "Value": name}],
                    }
                ],
            )

            pathId = response["NetworkInsightsPath"]["NetworkInsightsPathId"]

            if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
                print(f"failed to create {name}")
                sys.exit(1)

            # start analysis
            analysis = ec2.start_network_insights_analysis(
                NetworkInsightsPathId=response["NetworkInsightsPath"][
                    "NetworkInsightsPathId"
                ]
            )

            if analysis["ResponseMetadata"]["HTTPStatusCode"] != 200:
                print(f"failed to start analysis for {name}")
                sys.exit(1)

            aid = analysis["NetworkInsightsAnalysis"]["NetworkInsightsAnalysisId"]
            print(f"created {name}/{pathId}/{aid}")

            paths[name] = aid

    while True:
        running = 0

        for name, aid in paths.items():
            status = ec2.describe_network_insights_analyses(
                NetworkInsightsAnalysisIds=[aid]
            )["NetworkInsightsAnalyses"][0]["Status"]

            if status == "running":
                running += 1

                continue

            print(f"{name}: {status}")

        if running == 0:
            break

    pass


@cache
def ecs_clusters():
    args = {}

    ret = []
    client = boto3.client("ecs")

    while True:
        response = client.list_clusters(**args)

        for cluster in response["clusterArns"]:
            ret.append(cluster)

        if "NextToken" not in response:
            break

        args["NextToken"] = response["NextToken"]

    # print(f"ecs_clusters: {ret}")

    return ret


@cache
def ecs_services():
    args = {}

    ret = []
    client = boto3.client("ecs")

    for cluster in ecs_clusters():
        args["cluster"] = cluster

        while True:
            response = client.list_services(**args)

            for service in response["serviceArns"]:
                srv = client.describe_services(cluster=cluster, services=[service])
                ret.append(srv["services"][0])

            if "NextToken" not in response:
                break

            args["NextToken"] = response["NextToken"]

    return ret


def find_eni(comment=None, ecs=None):
    client = boto3.client("ec2")

    ret = {}

    args = {}

    while True:
        response = client.describe_network_interfaces(**args)

        for eni in response["NetworkInterfaces"]:

            # print(f"comment: {comment}, description: {eni['Description']}")

            if comment and re.search(comment, eni["Description"]):
                ret[eni["NetworkInterfaceId"]] = eni["AvailabilityZone"]

            if ecs:
                # print(f"ecs: {ecs}")

                for sg in eni["Groups"]:
                    # print(f"searching for sg {sg}")
                    sgid = sg["GroupId"]

                    for service in ecs_services():
                        # print(f"service: {service}")

                        if ecs != service["serviceName"]:
                            continue

                        service_sgs = service["networkConfiguration"][
                            "awsvpcConfiguration"
                        ]["securityGroups"]

                        # print(
                        # f"searching: {sgid} service name: {service['serviceName']}, sgs: {service_sgs}"
                        # )

                        if sgid in service_sgs:
                            # print(f"found sg {sg} in service {service}")
                            ret[eni["NetworkInterfaceId"]] = eni["AvailabilityZone"]

        if "NextToken" not in response:
            break

        args["NextToken"] = response["NextToken"]

    return ret


def lb(name):
    client = boto3.client("elbv2")

    try:
        response = client.describe_load_balancers(Names=[name])

        return response["LoadBalancers"][0]["LoadBalancerArn"]
    except:
        return None


if __name__ == "__main__":
    main()
