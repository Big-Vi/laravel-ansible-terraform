import sys
import boto3

def delete_s3_bucket_contents(bucket_name):
    s3_client = boto3.client('s3')
    objects = s3_client.list_objects_v2(Bucket=bucket_name)['Contents']
    
    for obj in objects:
        s3_client.delete_object(Bucket=bucket_name, Key=obj['Key'])
        print(f"Deleted {obj['Key']} from {bucket_name}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <bucket_name>")
        sys.exit(1)
    
    bucket_name = sys.argv[1]
    delete_s3_bucket_contents(bucket_name)
