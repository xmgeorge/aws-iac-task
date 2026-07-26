import json
from datetime import datetime, timezone


def handler(event, context):
    """Return the current UTC time as JSON."""
    now = datetime.now(timezone.utc)
    body = {
        "service": "current-time",
        "current_time_utc": now.isoformat(),
    }
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
