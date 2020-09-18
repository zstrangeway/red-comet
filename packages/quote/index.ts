import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Callback,
  Context,
  DynamoDBStreamEvent,
} from "aws-lambda"
import QuoteService from "./service"

const quoteService = new QuoteService()

exports.get = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  return await quoteService.getQuotes(event)
}

exports.getById = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  return await quoteService.getQuoteById(event)
}

exports.post = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  return await quoteService.addQuote(event, context)
}

exports.sendEmail = async (
  event: DynamoDBStreamEvent,
  _: Context,
  callback: Callback
) => {
  return quoteService.sendEmail(event, callback)
}
