import boto3
import json
import unittest
from moto import mock_dynamodb
from updateVisitorCount import lambda_handler

#@mock_dynamodb decorator mocks DynamoDB interactions for testing. Testing encapsulated within TestLambdaHandler class. 
@mock_dynamodb
class TestLambdaHandler(unittest.TestCase):
    def setUp(self):
        #function sets up testing environment where the mock DynamoDB table is configured and initialized. Uses same table as deployed in production.
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.create_table(
            TableName='VisitorCount',
            KeySchema=[{'AttributeName': 'visitorCount', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'visitorCount', 'AttributeType': 'S'}],
            ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
        )
        #table initialized with visitor count = 0 
        self.table.put_item(
            Item={'visitorCount': 'visitorCount', 'count': 0}
        )
    
    #lambda function testing. 
    def test_lambda_handler(self):
        #test event generation
        event = {}  
        context = {} 

        #passes event data into lambda function
        result = lambda_handler(event, context)

        #lambda function output validated against test case desired results. checks for correct status code and headers i.e content type and CORs origin. Throws a failure if lambda function output does not match test case assertions. 

        self.assertEqual(result["statusCode"], 200)
        self.assertEqual(result["headers"]["Content-Type"], 'application/json')
        self.assertEqual(result["headers"]["Access-Control-Allow-Origin"], 'https://saifbari.com')

        # validates the incrementing by 1 feature. As table is initialized to 0, any result but 1, will cause test to fail. 
        self.assertEqual(result["body"], 1)

#Runs as an independent unittest script.  If script is imported as a module in another script, the tests are not run.
if __name__ == '__main__':
    unittest.main()
