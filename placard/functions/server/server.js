// Express requirements
import bodyParser from 'body-parser'
import compression from 'compression'
import express from 'express'
import morgan from 'morgan'
import path from 'path'
import Loadable from 'react-loadable'
import cookieParser from 'cookie-parser'
import { establishReqUser } from './auth'

// Our routers
import auth from './auth'

// Our loader - this basically acts as the entry point for each page load
import loader from './loader'

// Create our express app using the port optionally specified
const app = express()
const PORT = process.env.PORT || 3000

// Compress, parse, log, and raid the cookie jar
app.use(compression())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(morgan('dev'))
app.use(cookieParser())

app.use(establishReqUser)

// Set up homepage, static assets, and capture everything else
app.use('/auth', auth)
app.use(express.Router().get('/', loader))
app.use(express.static(path.resolve(__dirname, '../app/build')))
app.use(loader)

// We tell React Loadable to load all required assets and start listening - ROCK AND ROLL!
Loadable.preloadAll()
  .then(() => {
    app.listen(PORT, console.log('[Render]', `app listening on port ${PORT}`))
  })
  .catch(err => {
    console.log('[Render]', 'preloadAll', 'error', err)
  })

// Handle the bugs somehow
app.on('error', error => {
  if (error.syscall !== 'listen') {
    throw error
  }

  const bind = typeof PORT === 'string' ? 'Pipe ' + PORT : 'Port ' + PORT

  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' requires elevated privileges')
      process.exit(1)
      break
    case 'EADDRINUSE':
      console.error(bind + ' is already in use')
      process.exit(1)
      break
    default:
      throw error
  }
})

console.log('[Render]', 'server initialized')

module.exports = app
