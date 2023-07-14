# Triggered thru lambda event, and increments Visitor Count in a DynamoDB table
# Retrieves updated count in the return response.

import boto3


def lambda_handler(event, context):
    # Instantiate a dynamoDB object and reference VisitorCount table
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('VisitorCount')

    # Increment visitor count in DynamoDB table
    table.update_item(
        Key={'visitorCount': 'visitorCount'},
        ExpressionAttributeValues={
            ':inc': 1
        },
        ExpressionAttributeNames={
            "#count": "count"
        },
        UpdateExpression='ADD #count :inc'
    )
    # Retrieves updated visitor count from DynamoDB table
    total_viewers = table.get_item(
        Key={'visitorCount': 'visitorCount'}
    )
    new_viewers = int(total_viewers["Item"]["count"])

    # Return's HTTP respone with status code, headers, and visitor count
    return {
        "statusCode": 200,
        "headers": {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': 'https://saifbari.com'
        },
        "body": new_viewers
    }
