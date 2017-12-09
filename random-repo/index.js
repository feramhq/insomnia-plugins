const request = require('request-promise-native')

const {templateTags, getRequestOptions} = require('./output/Main')


function sample (array) {
  const length = array == null ? 0 : array.length
  return length ? array[Math.floor(Math.random() * length)] : undefined
}

async function getResponse (context, token, queryString) {
  token = String(token || '')
  queryString = String(queryString || '')

  const now = Date.now()

  const requestOptions = getRequestOptions(token)(queryString)(now)
  console.info('Request options:', requestOptions)

  const searchResponse = await request(requestOptions)

  return searchResponse
}


templateTags[0].run = async function (context, token, queryString) {
  const numberOfRetries = 100
  let counter = 0
  let searchObject

  do {
    console.info(`Try to load random repo. Retry number ${counter}`)
    const searchResponse = await getResponse(context, token, queryString)
    searchObject = JSON.parse(searchResponse)
    counter += 1
  }
  while (
    searchObject.total_count === 0 &&
    counter < numberOfRetries
  )

  if (counter >= numberOfRetries) {
    throw new Error(`Request timed out after ${numberOfRetries} retries`)
  }

  const selectedRepo = sample(searchObject.items)

  return selectedRepo.full_name
}


module.exports = {templateTags}
