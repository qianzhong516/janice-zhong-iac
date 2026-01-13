import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient();

export const handler = async () => {
  await client.send(
    new UpdateItemCommand({
      TableName: "visits",
      Key: {
        id: { S: "1" },
      },
      UpdateExpression: "ADD visitCount :inc",
      ExpressionAttributeValues: {
        ":inc": { N: "1" },
      },
    })
  );

  console.log(
    JSON.stringify({
      level: "info",
      message: "User visit recorded",
      requestId: context.awsRequestId,
      date: new Date().toISOString().slice(0, 10), // YYYY-MM-DD
    })
  );

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Visits incremented" }),
  };
};
