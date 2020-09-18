/* eslint-disable @typescript-eslint/no-unused-vars */
import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Callback,
  Context,
  DynamoDBStreamEvent,
} from "aws-lambda"
import { SuccessResponse } from "/opt/models"

export default class QuoteService {
  getQuotes = async (
    event: APIGatewayProxyEvent
  ): Promise<APIGatewayProxyResult> => {
    return new SuccessResponse("Function not implemented")
  }

  getQuoteById = async (
    event: APIGatewayProxyEvent
  ): Promise<APIGatewayProxyResult> => {
    return new SuccessResponse("Function not implemented")
  }

  addQuote = async (
    event: APIGatewayProxyEvent,
    context: Context
  ): Promise<APIGatewayProxyResult> => {
    return new SuccessResponse("Function not implemented")
  }

  sendEmail = (event: DynamoDBStreamEvent, callback: Callback): void => {
    // TODO: Implement
  }
}
