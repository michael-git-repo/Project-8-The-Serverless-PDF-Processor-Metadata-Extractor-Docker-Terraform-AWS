import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";
import pdfParse from "pdf-parse";

const s3Client = new S3Client({});
const dbClient = new DynamoDBClient({});

export const handler = async (event) => {
  try {
    const record = event.Records[0];
    const bucketName = record.s3.bucket.name;
    const objectKey = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

    // 1. Fetch file from S3
    const s3Response = await s3Client.send(
      new GetObjectCommand({
        Bucket: bucketName,
        Key: objectKey,
      })
    );

    // Convert stream to buffer
    const streamToBuffer = async (stream) => {
      const chunks = [];
      for await (const chunk of stream) {
        chunks.push(chunk);
      }
      return Buffer.concat(chunks);
    };

    const pdfBuffer = await streamToBuffer(s3Response.Body);

    // 2. Parse PDF content
    const parsedPdf = await pdfParse(pdfBuffer);

    // 3. Prepare metadata item
    const metadata = {
      pdf_id: objectKey,
      upload_timestamp: new Date().toISOString(),
      num_pages: parsedPdf.numpages,
      info: parsedPdf.info || {},
      text_snippet: parsedPdf.text.slice(0, 500), // First 500 chars
    };

    // 4. Save to DynamoDB
    const tableName = process.env.DYNAMODB_TABLE_NAME;
    await dbClient.send(
      new PutItemCommand({
        TableName: tableName,
        Item: marshall(metadata),
      })
    );

    console.log(`Successfully processed ${objectKey} and saved to ${tableName}`);
    return { statusCode: 200, body: JSON.stringify({ message: "Success" }) };
  } catch (error) {
    console.error("Error processing PDF:", error);
    throw error;
  }
};