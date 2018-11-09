const request = require('request-promise')


function sample (array) {
  const length = array == null ? 0 : array.length
  return length ? array[Math.floor(Math.random() * length)] : undefined
}


function formatWithOffset (date) {
  return date
    .toISOString()
    .replace(/\.\d{3}Z$/, '+00:00')
}


function getQueryObject (query) {
  if (typeof query === 'string' && query !== '') {
    return {
      q: query, // eslint-disable-line id-length
    }
  }

  const maxDaysAgo = 300
  const randomMoment = new Date()
  // Smaller than 10 Mb
  query = 'size:<10000 '

  randomMoment.setUTCDate(
    randomMoment.getUTCDate() - Math.trunc(Math.random() * maxDaysAgo)
  )
  const randomMomentOffset = new Date(randomMoment)
  randomMomentOffset.setUTCHours(randomMomentOffset.getUTCHours() + 2)

  query += 'pushed:"' +
    formatWithOffset(randomMoment) +
    ' .. ' +
    formatWithOffset(randomMomentOffset) +
    '"'

  return {
    q: query, // eslint-disable-line id-length
    sort: 'updated',
    per_page: 1, // eslint-disable-line camelcase
  }
}


async function run (context, token, queryString) {
  const requestOptions = {
    uri: 'https://api.github.com/search/repositories',
    headers: {
      'User-Agent': 'feram',
    },
    qs: getQueryObject(queryString),
  }

  if (token) {
    requestOptions.headers.Authorization = `token ${token}`
  }

  const searchResponse = await request(requestOptions)
  const searchObject = JSON.parse(searchResponse)
  const selectedRepo = sample(searchObject.items)

  return requestOptions
  return selectedRepo.full_name
}


const templateTags = [{
  name: 'RandomRepo',
  displayName: 'Random Repo',
  description: 'Get a random GitHub repo name',
  args: [
    {
      displayName: 'Authorization Token',
      description: 'Token to increase rate limit for search queries',
      type: 'string',
      defaultValue: '',
    },
    {
      displayName: 'Search String',
      description: 'Explicit search string instead of one for a random repo',
      type: 'string',
      defaultValue: '',
    },
  ],
  run,
}]


module.exports.templateTags = templateTags

run().then(console.dir)
