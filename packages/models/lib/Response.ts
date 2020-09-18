import { APIGatewayProxyResult } from "aws-lambda"

export class Response implements APIGatewayProxyResult {
  statusCode: number
  headers?: { [header: string]: string | number | boolean } | undefined
  multiValueHeaders?:
    | { [header: string]: (string | number | boolean)[] }
    | undefined
  body: string
  isBase64Encoded?: boolean | undefined

  constructor(statusCode: number, body: string) {
    this.statusCode = statusCode
    this.body = body
    this.headers = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": true,
      "Content-Type": "application/json",
    }
  }
}

export class ErrorResponse extends Response {
  constructor(statusCode: number, errorMessage: string) {
    super(statusCode, `{ "error": "${errorMessage}" }`)
  }
}

export class SuccessResponse extends Response {
  constructor(body: string) {
    super(200, body)
  }
}
