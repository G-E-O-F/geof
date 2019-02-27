const functions = require('firebase-functions')

console.log('[Cloud functions]', '`render` function mounting')

const renderServer = require('./server')

exports.render = functions.https.onRequest(renderServer)
