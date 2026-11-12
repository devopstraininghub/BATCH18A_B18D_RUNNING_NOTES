import os

import boto3

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

TAG_KEY = "AutoStop"
TAG_VALUE = "true"


def find_instances(states):
    """Return IDs of instances tagged AutoStop=true that are in the given states."""
    ids = []
    paginator = ec2.get_paginator("describe_instances")
    pages = paginator.paginate(
        Filters=[
            {"Name": f"tag:{TAG_KEY}", "Values": [TAG_VALUE]},
            {"Name": "instance-state-name", "Values": states},
        ]
    )
    for page in pages:
        for reservation in page["Reservations"]:
            for inst in reservation["Instances"]:
                ids.append(inst["InstanceId"])
    return ids


def lambda_handler(event, context):
    action = event.get("action")
    if action not in ("stop", "start"):
        raise ValueError('Event must be {"action": "stop"} or {"action": "start"}')

    dry_run = os.environ.get("DRY_RUN", "true").lower() == "true"

    # 1. Find the instances (only ones that actually need to change)
    if action == "stop":
        ids = find_instances(["running"])
    else:
        ids = find_instances(["stopped"])

    # 2. Stop or start them (skipped in dry-run mode)
    if ids and not dry_run:
        if action == "stop":
            ec2.stop_instances(InstanceIds=ids)
        else:
            ec2.start_instances(InstanceIds=ids)

    # 3. Write the report
    mode = "DRY RUN (nothing changed)" if dry_run else "LIVE"
    verb = "Stopped" if action == "stop" else "Started"
    lines = [
        f"Auto-{action} report [{mode}]",
        f"{verb if not dry_run else 'Would have ' + verb.lower()}: {len(ids)} instance(s)",
        "",
    ]
    lines += ids or ["No matching instances."]
    report = "\n".join(lines)
    print(report)

    # 4. Email it
    sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject=f"EC2 auto-{action}: {len(ids)} instance(s)",
        Message=report,
    )
    return {"action": action, "count": len(ids), "dry_run": dry_run}
