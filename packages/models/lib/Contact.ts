export class Contact {
  id: string
  email: string
  name: string
  date: number
  subject: string
  message: string

  constructor(
    id: string,
    email: string,
    name: string,
    date: number,
    subject: string,
    message: string
  ) {
    this.id = id
    this.email = email
    this.name = name
    this.date = date
    this.subject = subject
    this.message = message
  }
}
