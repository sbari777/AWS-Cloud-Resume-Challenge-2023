import boto3


def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('VisitorCount')
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

    total_viewers = table.get_item(
        Key={'visitorCount': 'visitorCount'}
    )
    new_viewers = int(total_viewers["Item"]["count"])
    print(new_viewers)

    return {
        "statusCode": 400,
        "headers": {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': 'https://saifbari.com'
        },
        "body": new_viewers
    }
