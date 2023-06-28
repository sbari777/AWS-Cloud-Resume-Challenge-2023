import boto3
import json
import unittest
from moto import mock_dynamodb
from updateVisitorCount import lambda_handler

#@mock_dynamodb decorator is used to mock DynamoDB interactions for testing. Declares an unittest class which encapsulates a test case.
@mock_dynamodb
class TestLambdaHandler(unittest.TestCase):
    def setUp(self):
        #this function sets up the environment for each test. This is where the mock DynamoDB table is created and initialized. It has the same schema and settings as the DynamoDB table in production. 
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.create_table(
            TableName='VisitorCount',
            KeySchema=[{'AttributeName': 'visitorCount', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'visitorCount', 'AttributeType': 'S'}],
            ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
        )
        #The table has been initialized to have the visitor counter set to 0. 
        self.table.put_item(
            Item={'visitorCount': 'visitorCount', 'count': 0}
        )
    #This section tests the lambda function by create an test event, which in this case is empty because event case is the triggering of the function via an api gateway invocation.
    def test_lambda_handler(self):
        #test event generation
        event = {}  
        context = {} 

        # run the Lambda function, passes the empty event data as declared in the event and context variables above
        result = lambda_handler(event, context)

        #This is where the output of the lambda function is validated against the test cases's desired results. It checks that status code is set to 200, that the content type header is set to 'application/json', and that CORs domain is set correctly. If the lambda function shows any deviation from those settings, i.e status code = 400 , or CORs domain = http://example.com, then the test will throw an failure
        
        self.assertEqual(result["statusCode"], 200)
        self.assertEqual(result["headers"]["Content-Type"], 'application/json')
        self.assertEqual(result["headers"]["Access-Control-Allow-Origin"], 'https://saifbari.com')

        # this is the test case which checks that it increments by adding 1. Since the table is initiazlied to 0, the end result should be 1. If the lambda is modified to i.e increment by 5, then an error would be throw since that would be 5 and not 1. 
        self.assertEqual(result["body"], 1)

#this specifies that this runs as an independent unittest script.  If the script is imported as a module in another script, the tests are not run.
if __name__ == '__main__':
    unittest.main()
