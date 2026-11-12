import os
from datetime import date, timedelta

import boto3

ce = boto3.client("ce", region_name="us-east-1")   # Cost Explorer lives in us-east-1
sns = boto3.client("sns")


def lambda_handler(event, context):
    today = date.today()
    yesterday = today - timedelta(days=1)

    # 1. Ask Cost Explorer for yesterday's cost, split by service
    resp = ce.get_cost_and_usage(
        TimePeriod={"Start": str(yesterday), "End": str(today)},
        Granularity="DAILY",
        Metrics=["UnblendedCost"],
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
    )
    groups = resp["ResultsByTime"][0]["Groups"]
    costs = {g["Keys"][0]: float(g["Metrics"]["UnblendedCost"]["Amount"]) for g in groups}

    # 2. Write the report
    lines = [
        f"AWS report for {yesterday}",
        f"Services used: {len(costs)}",
        f"Total cost: ${sum(costs.values()):.2f}",
        "",
    ]
    for name, cost in sorted(costs.items(), key=lambda x: x[1], reverse=True):
        lines.append(f"{name}: ${cost:.2f}")
    report = "\n".join(lines)
    print(report)

    # 3. Email it
    sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject=f"AWS report {yesterday}",
        Message=report,
    )
    return {"sent": True}
