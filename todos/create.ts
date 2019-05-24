'use strict'

import * as uuid from 'uuid'

module.exports.create = (event, context, callback) => {
  const timestamp = new Date().getTime()
  const data = JSON.parse(event.body)
  if (typeof data.text !== 'string') {
    console.error('Validation Failed')
    callback(new Error('Couldn\'t create the todo item.'))
    return
  }

  // create a response
  const response = {
    statusCode: 200,
    body: JSON.stringify({ hello: "world" })
  }
  callback(null, response)
}
