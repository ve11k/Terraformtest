import boto3
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    key_lower = key.lower()

    try:
        response = s3.head_object(Bucket=bucket, Key=key)
        size = response['ContentLength']
    except Exception as e:
        print(f"Failed to get object size: {e}")
        return

    if size > 1024 * 1024:
        s3.delete_object(Bucket=bucket, Key=key)
        print(f"Deleted {key}, too large")
        return

    if key_lower.startswith("zvit-"):
        target_bucket = os.environ['ZVIT_BUCKET']
    elif key_lower.startswith("forecast-"):
        target_bucket = os.environ['FORECAST_BUCKET']
    else:
        print("Unknown file type, ignoring")
        return

    try:
        copy_source = {'Bucket': bucket, 'Key': key}
        s3.copy_object(CopySource=copy_source, Bucket=target_bucket, Key=key)
        s3.delete_object(Bucket=bucket, Key=key)
        print(f"Moved {key} to {target_bucket}")
    except Exception as e:
        print(f"Error while moving file: {e}")