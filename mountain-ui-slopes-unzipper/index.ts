import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

export async function handler(event, context) {
    const client = new S3Client({ region: "us-west-2" });

    for (let record of event.Records) {
        const bucket = decodeURI(record.s3.bucket.name);
        const fileName = decodeURI(record.s3.object.key);

        const command = new GetObjectCommand({ Bucket: bucket, Key: fileName });
        const response = await client.send(command);

        console.log(response);
    }
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Go Serverless v1.0! Your function executed successfully!",
            input: event
        })
    };
}
