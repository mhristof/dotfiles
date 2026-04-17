#!/usr/bin/env python3

import boto3
import sys
import time


def get_instance_id_by_name(ec2_client, instance_name):
    """
    Find the EC2 instance ID by Name tag.
    """
    response = ec2_client.describe_instances(
        Filters=[
            {"Name": "tag:Name", "Values": [instance_name]},
            {
                "Name": "instance-state-name",
                "Values": ["pending", "running", "stopping", "stopped"],
            },
        ]
    )

    reservations = response.get("Reservations", [])
    if not reservations:
        return None

    # Return the first matching instance ID
    for reservation in reservations:
        for instance in reservation["Instances"]:
            return instance["InstanceId"]
    return None


def get_attached_volumes(ec2_client, instance_id):
    """
    Return a list of attached volumes with device info and type (root/data).
    """
    response = ec2_client.describe_instances(InstanceIds=[instance_id])
    instance = response["Reservations"][0]["Instances"][0]

    root_device_name = instance.get("RootDeviceName", "")

    volumes = []
    for bd in instance.get("BlockDeviceMappings", []):
        if "Ebs" not in bd:
            continue
        volume_id = bd["Ebs"]["VolumeId"]
        device_name = bd.get("DeviceName", "")
        volume_type = "root" if device_name == root_device_name else "data"
        volumes.append(
            {
                "volume_id": volume_id,
                "device_name": device_name,
                "volume_type": volume_type,
            }
        )
    return volumes


def create_snapshots_and_wait(ec2_client, volumes, instance_name):
    """
    Create snapshots for data volumes and wait for them to complete.
    """
    snapshot_ids = []

    for vol in volumes:
        if vol["volume_type"] != "data":
            continue  # Skip root volume

        print(f"Creating snapshot for {vol['volume_id']} ({vol['device_name']})...")
        response = ec2_client.create_snapshot(
            VolumeId=vol["volume_id"],
            Description=f"Snapshot of {vol['volume_id']} from instance {instance_name}",
        )
        snapshot_id = response["SnapshotId"]
        snapshot_ids.append(snapshot_id)
        print(f" - Snapshot {snapshot_id} started.")

    if not snapshot_ids:
        print("No data volumes found to snapshot.")
        return

    # Wait for all snapshots to complete
    print("\nWaiting for snapshots to complete...")
    waiter = ec2_client.get_waiter("snapshot_completed")
    for snapshot_id in snapshot_ids:
        print(f"Waiting for snapshot {snapshot_id}...")
        waiter.wait(SnapshotIds=[snapshot_id])
        print(f" - Snapshot {snapshot_id} completed.")

    print("\nAll snapshots completed.")
    print("Snapshot IDs:")
    for sid in snapshot_ids:
        print(f" - {sid}")


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <instance_name>")
        sys.exit(1)

    instance_name = sys.argv[1]
    ec2_client = boto3.client("ec2")

    instance_id = get_instance_id_by_name(ec2_client, instance_name)
    if not instance_id:
        print(f"Instance with Name '{instance_name}' not found.")
        sys.exit(1)

    print(f"Found instance ID: {instance_id}")

    volumes = get_attached_volumes(ec2_client, instance_id)
    if not volumes:
        print("No volumes attached.")
        sys.exit(0)

    print("Attached volumes:")
    for vol in volumes:
        print(f" - {vol['volume_id']} ({vol['device_name']}): {vol['volume_type']}")

    create_snapshots_and_wait(ec2_client, volumes, instance_name)


if __name__ == "__main__":
    main()
