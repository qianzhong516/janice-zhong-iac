import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient();
const TABLE_NAME = process.env.TABLE_NAME;

export const handler = async () => {
  const res = await client.send(
    new GetItemCommand({
      TableName: TABLE_NAME,
      Key: {
        id: { S: "1" },
      },
    })
  );

  const totalCount = res.Item?.visitCount?.N
    ? Number(res.Item.visitCount.N)
    : 0;

  return {
    statusCode: 200,
    body: JSON.stringify({ totalCount }),
  };
};
