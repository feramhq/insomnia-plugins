const request = require('request')

exports.fetchImpl = function (options, done, fail) {
  return function () {
    request(
      options,
      (error, _, body) => {
        if (error) fail(error)()
        else done(body)()
      }
    )
  }
}


// TODO: Also possible Solution
// function sample (array) {
//   const length = array == null ? 0 : array.length
//   return length ? array[Math.floor(Math.random() * length)] : undefined
// }

// exports.getRunImpl = function (requestOptions, done, fail) {
//   return function (context, token, queryString) {
//     const searchResponse = request(
//       requestOptions,
//       function (error, _, body) {
//         if (error) {
//           fail(error)()
//         }
//         else {
//           const searchObject = JSON.parse(body)
//           const selectedRepo = sample(searchObject.items)
//           done(selectedRepo.full_name)()
//         }
//       }
//     )
//   }
// }
