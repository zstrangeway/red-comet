import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Callback,
  Context,
  DynamoDBStreamEvent,
} from "aws-lambda"
import { SES } from "aws-sdk"
import { DocumentClient } from "aws-sdk/clients/dynamodb"
import ContactService from "./service"

const docClient = new DocumentClient()
const ses = new SES()
const contactService = new ContactService(docClient, ses)

exports.get = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  return await contactService.getContacts(event)
}

exports.getById = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  return await contactService.getContactById(event)
}

exports.post = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  return await contactService.addContact(event, context)
}

exports.sendEmail = async (
  event: DynamoDBStreamEvent,
  _: Context,
  callback: Callback
) => {
  return contactService.sendEmail(event, callback)
}
