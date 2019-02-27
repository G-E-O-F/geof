// Express requirements
import path from 'path'
import fs from 'fs'
import url from 'url'

// React requirements
import React from 'react'
import { renderToString } from 'react-dom/server'
import Helmet from 'react-helmet'
import { Provider } from 'react-redux'
import { StaticRouter } from 'react-router'
import { Frontload, frontloadServerRender } from 'react-frontload'
import Loadable from 'react-loadable'
import { JssProvider, SheetsRegistry } from 'react-jss'
import { ThemeProvider } from '../app/src/style'
import { createGenerateClassName } from '@material-ui/core/styles'

// Our store, entrypoint, and manifest
import createStore from '../app/src/store'
import App from '../app/src/App'
import manifest from '../app/build/asset-manifest.json'

// Some optional Redux functions related to user authentication
import { setCurrentUserFromCookie, logoutUser } from '../app/src/modules/auth'

const injectHTML = (data, { html, title, meta, body, scripts, state }) => {
  data = data.replace('<html>', `<html ${html}>`)
  data = data.replace(/<title>.*?<\/title>/g, title)
  data = data.replace('</head>', `${meta}</head>`)
  data = data.replace(
    '<div id="root"></div>',
    `<div id="root">${body}</div><script>window.__PRELOADED_STATE__ = ${state}</script>`
  )
  data = data.replace('</body>', scripts.join('') + '</body>')

  return data
}

const settleStore = req => {
  // Create a store (with a memory history) from our current url
  const { store } = createStore(req.url)

  // If the user has a cookie (i.e. they're signed in) - set them as the current user
  // Otherwise, we want to set the current state to be logged out, just in case this isn't the default
  if (req.user) {
    return store
      .dispatch(dispatch => {
        console.log('[SSR]', 'authenticated', req.user)
        return Promise.all([dispatch(setCurrentUserFromCookie(req.user))])
      })
      .then(() => store)
  } else {
    console.log('[SSR]', 'not authenticated')
    return store.dispatch(logoutUser()).then(() => store)
  }
}

const settleMarkup = ({ store, req }) => {
  // Set up accumulators for SSR
  const context = {}
  const modules = []
  const sheets = new SheetsRegistry()
  const generateClassName = createGenerateClassName()
  const sheetsManager = new Map()

  /*
    Here's the core funtionality of this file. We do the following in specific order (inside-out):
      1. Load the <App /> component
      2. Inside of the Frontload HOC
      3. Inside of a Redux <StaticRouter /> (since we're on the server), given a location and
        context to write to
      4. Inside of the store provider
      5. Inside of the React Loadable HOC to make sure we have the right scripts depending
      6. Inside of the JSS provider to capture all the styles used on the page
      7. Render all of this sexiness
      8. Make sure that when rendering Frontload knows to get all the appropriate preloaded
       requests
    In English, we basically need to know what page we're dealing with, and then load all the appropriate scripts and
    data for that page. We take all that information and compute the appropriate state to send to the user. This is
    then loaded into the correct components and sent as a Promise to be handled below.
  */

  return frontloadServerRender(() =>
    renderToString(
      <JssProvider registry={sheets} generateClassName={generateClassName}>
        <ThemeProvider sheetsManager={sheetsManager}>
          <Loadable.Capture report={m => modules.push(m)}>
            <Provider store={store}>
              <StaticRouter location={req.url} context={context}>
                <Frontload isServer={true}>
                  <App />
                </Frontload>
              </StaticRouter>
            </Provider>
          </Loadable.Capture>
        </ThemeProvider>
      </JssProvider>
    )
  ).then(routeMarkup => ({ store, routeMarkup, sheets, context, modules }))
}

// LOADER
export default (req, res) => {
  /*
    A simple helper function to prepare the HTML markup. This loads:
      - Page title
      - SEO meta tags
      - Preloaded state (for Redux) depending on the current route
      - Code-split script tags depending on the current route
  */

  // Load in our HTML file from our build
  fs.readFile(
    path.resolve(__dirname, '../app/build/basepage.html'),
    'utf8',
    (err, htmlData) => {
      // If there's an error... serve up something nasty
      if (err) {
        console.error('Read error', err)
        return res.status(404).end()
      }

      settleStore(req)
        .then(store => settleMarkup({ store, req }))
        .then(({ store, routeMarkup, sheets, context, modules }) => {
          if (context.url) {
            // If context has a url property, then we need to handle a redirection in Redux Router
            res.writeHead(302, {
              Location: context.url,
            })

            res.end()
          } else {
            // Otherwise, we carry on...
            // Let's give ourself a function to load all our page-specific JS assets for code splitting
            const extractAssets = (assets, chunks) =>
              Object.keys(assets)
                .filter(asset => chunks.indexOf(asset.replace('.js', '')) > -1)
                .map(k => assets[k])

            // Render the stylesheet for this page
            const ssrStyles = `<style type="text/css" id="server-side-styles">${sheets.toString()}</style>`

            // Let's format those assets into pretty <script> tags
            const extraChunks = extractAssets(manifest, modules).map(
              c =>
                `<script type="text/javascript" src="/${c.replace(
                  /^\//,
                  ''
                )}"></script>`
            )

            // We need to tell Helmet to compute the right meta tags, title, and such
            const helmet = Helmet.renderStatic()

            // Pass all this nonsense into our HTML formatting function above
            const html = injectHTML(htmlData, {
              html: helmet.htmlAttributes.toString(),
              title: helmet.title.toString(),
              meta: helmet.meta.toString() + ssrStyles,
              body: routeMarkup,
              scripts: extraChunks,
              state: JSON.stringify(store.getState()).replace(/</g, '\\u003c'),
            })

            // Log to confirm SSR (vs client-side render)
            console.log('[Render]', 'rendered page', routeMarkup.length)

            // We have all the final HTML, let's send it to the user already!
            res.send(html)
          }
        })
        .catch(err => {
          console.log('[loader]', 'error', err)
          res.sendStatus(500)
        })
    }
  )
}
