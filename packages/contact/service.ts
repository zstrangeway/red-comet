import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Callback,
  Context,
  DynamoDBStreamEvent,
} from "aws-lambda"
import { SES } from "aws-sdk"
import { DocumentClient } from "aws-sdk/clients/dynamodb"
import { SendEmailRequest } from "aws-sdk/clients/ses"
import { Contact, ErrorResponse, SuccessResponse } from "/opt/models"
import { checkParams } from "/opt/common/"

export default class ContactService {
  docClient: DocumentClient
  ses: SES

  constructor(docClient: DocumentClient, ses: SES) {
    this.docClient = docClient
    this.ses = ses
  }

  getContacts = async (
    event: APIGatewayProxyEvent
  ): Promise<APIGatewayProxyResult> => {
    const nextToken = event.headers.nextToken
      ? { id: `${event.headers.nextToken}` }
      : undefined
    const params = {
      TableName: `${process.env.CONTACT_TABLE}`,
      Limit: 25,
      ExclusiveStartKey: nextToken,
    }

    try {
      const query = await this.docClient.scan(params).promise()
      return new SuccessResponse(JSON.stringify(query.Items))
    } catch (err) {
      return new ErrorResponse(503, "Unable to retrieve records at this time.")
    }
  }

  getContactById = async (
    event: APIGatewayProxyEvent
  ): Promise<APIGatewayProxyResult> => {
    
    if (!event.pathParameters.id)
      return new ErrorResponse(400, "Missing User ID")

    const id = event.pathParameters.id

    const params = {
      TableName: `${process.env.CONTACT_TABLE}`,
      Key: {
        id,
      },
    }

    try {
      const contact = await this.docClient.get(params).promise()
      return contact.Item
        ? new SuccessResponse(JSON.stringify(contact.Item))
        : new ErrorResponse(404, `No users found with id: ${id}`)
    } catch (err) {
      console.log(err)
      return new ErrorResponse(503, "Unable to process request at this time.")
    }
  }

  addContact = async (
    event: APIGatewayProxyEvent,
    context: Context
  ): Promise<APIGatewayProxyResult> => {
    if (!event.body)
      return new ErrorResponse(400, "Error: Request missing body.")

    const body = JSON.parse(event.body)
    const missingParams = checkParams(body, [
      "email",
      "name",
      "subject",
      "message",
    ])
    if (missingParams.length > 0)
      return new ErrorResponse(
        400,
        `Unable to process request. Missing parameters: ${missingParams.join(
          ", "
        )}`
      )

    const contact = new Contact(
      context.awsRequestId,
      body.email,
      body.name,
      Math.floor(new Date().getTime() / 1000.0),
      body.subject,
      body.message
    )

    const params = {
      TableName: `${process.env.CONTACT_TABLE}`,
      Item: contact,
    }

    try {
      await this.docClient.put(params).promise()
      return new SuccessResponse(JSON.stringify(contact))
    } catch (err) {
      console.log(err)
      return new ErrorResponse(503, "Unable to process request at this time.")
    }
  }

  sendEmail = (event: DynamoDBStreamEvent, callback: Callback): void => {
    const successes = 0
    const errors: Array<string> = []

    event.Records.forEach(async (record) => {
      if (record.eventName === "INSERT") {
        const email = record.dynamodb.NewImage.email.S
          ? `${record.dynamodb.NewImage.email.S}`
          : "_blank"
        const name = record.dynamodb.NewImage.name.S
          ? `${record.dynamodb.NewImage.name.S}`
          : "_blank"
        const subject = record.dynamodb.NewImage.subject.S
          ? `${record.dynamodb.NewImage.subject.S}`
          : "_blank"
        const message = record.dynamodb.NewImage.message.S
          ? `${record.dynamodb.NewImage.message.S}`
          : "_blank"

        const emailSubject = `New message from Red Comet website: ${subject}`
        const emailMessage = `Name: ${name}
  
Email: ${email}

Subject: ${subject}

Message:

${message}`

        const params: SendEmailRequest = {
          Source: `${process.env.FROM_EMAIL}`,
          Destination: {
            ToAddresses: [`${process.env.TO_EMAIL}`],
          },
          Message: {
            Subject: { Data: emailSubject },
            Body: {
              Text: { Data: emailMessage },
            },
          },
        }

        try {
          await this.ses.sendEmail(params).promise()
        } catch (err) {
          errors.push(JSON.stringify(err))
          console.log(JSON.stringify(err, null, 2))
        }
      }
    })

    if (errors.length === 0) {
      callback(null, `Successfully processed ${successes} records.`)
    } else {
      const errorsJoined = errors.join(";")
      callback(
        `Failed to send ${errors.length} messages. Errors: ${errorsJoined}`,
        null
      )
    }
  }
}
