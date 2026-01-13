import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient();
const TABLE_NAME = process.env.TABLE_NAME;

export const handler = async (event, context) => {
  await client.send(
    new UpdateItemCommand({
      TableName: TABLE_NAME,
      Key: {
        id: { S: "1" },
      },
      UpdateExpression: "ADD visitCount :inc",
      ExpressionAttributeValues: {
        ":inc": { N: "1" },
      },
    })
  );

  console.log({
    message: "User visit recorded",
    level: "info",
    requestId: context.awsRequestId,
    date: new Date().toISOString().slice(0, 10), // YYYY-MM-DD
  });

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Visits incremented" }),
  };
};
