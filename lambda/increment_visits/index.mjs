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

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Visits incremented" }),
  };
};
